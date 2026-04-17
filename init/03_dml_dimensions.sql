-- =============================================================
-- 03_dml_dimensions.sql
-- Заполнение таблиц-измерений из сырых данных mock_data
-- Порядок важен: сначала независимые измерения,
-- затем зависящие от них
-- =============================================================


-- ----------------------------
-- 1. dim_location
-- Объединяем все источники географии:
--   customers, sellers, stores, suppliers
-- NULL → '' для корректного UNIQUE-ограничения
-- ----------------------------
INSERT INTO dim_location (country, city, state, postal_code)
SELECT DISTINCT
    COALESCE(NULLIF(customer_country, ''),    ''),
    '',
    '',
    COALESCE(NULLIF(customer_postal_code, ''), '')
FROM mock_data
WHERE customer_country IS NOT NULL AND customer_country != ''

UNION

SELECT DISTINCT
    COALESCE(NULLIF(seller_country, ''),    ''),
    '',
    '',
    COALESCE(NULLIF(seller_postal_code, ''), '')
FROM mock_data
WHERE seller_country IS NOT NULL AND seller_country != ''

UNION

SELECT DISTINCT
    COALESCE(NULLIF(store_country, ''), ''),
    COALESCE(NULLIF(store_city,    ''), ''),
    COALESCE(NULLIF(store_state,   ''), ''),
    ''
FROM mock_data
WHERE store_country IS NOT NULL AND store_country != ''

UNION

SELECT DISTINCT
    COALESCE(NULLIF(supplier_country, ''), ''),
    COALESCE(NULLIF(supplier_city,    ''), ''),
    '',
    ''
FROM mock_data
WHERE supplier_country IS NOT NULL AND supplier_country != ''

ON CONFLICT ON CONSTRAINT uq_location DO NOTHING;


-- ----------------------------
-- 2. dim_pet_breed
-- ----------------------------
INSERT INTO dim_pet_breed (pet_type, breed_name)
SELECT DISTINCT
    LOWER(TRIM(customer_pet_type)),
    TRIM(customer_pet_breed)
FROM mock_data
WHERE customer_pet_type IS NOT NULL AND customer_pet_type != ''
  AND customer_pet_breed IS NOT NULL AND customer_pet_breed != ''
ON CONFLICT ON CONSTRAINT uq_pet_breed DO NOTHING;


-- ----------------------------
-- 3. dim_pet_category
-- ----------------------------
INSERT INTO dim_pet_category (category_name)
SELECT DISTINCT TRIM(pet_category)
FROM mock_data
WHERE pet_category IS NOT NULL AND pet_category != ''
ON CONFLICT ON CONSTRAINT uq_pet_category DO NOTHING;


-- ----------------------------
-- 4. dim_product_category
-- ----------------------------
INSERT INTO dim_product_category (category_name)
SELECT DISTINCT TRIM(product_category)
FROM mock_data
WHERE product_category IS NOT NULL AND product_category != ''
ON CONFLICT ON CONSTRAINT uq_product_category DO NOTHING;


-- ----------------------------
-- 5. dim_brand
-- ----------------------------
INSERT INTO dim_brand (brand_name)
SELECT DISTINCT TRIM(product_brand)
FROM mock_data
WHERE product_brand IS NOT NULL AND product_brand != ''
ON CONFLICT ON CONSTRAINT uq_brand DO NOTHING;


-- ----------------------------
-- 6. dim_customer
-- Берём первую запись для каждого уникального email
-- Присоединяем dim_location и dim_pet_breed
-- ----------------------------
INSERT INTO dim_customer (first_name, last_name, age, email, pet_name, location_id, pet_breed_id)
SELECT DISTINCT ON (m.customer_email)
    m.customer_first_name,
    m.customer_last_name,
    NULLIF(m.customer_age, '')::INTEGER,
    m.customer_email,
    m.customer_pet_name,
    l.id,
    pb.id
FROM mock_data m
JOIN dim_location l
    ON  l.country     = COALESCE(NULLIF(m.customer_country,     ''), '')
    AND l.city        = ''
    AND l.state       = ''
    AND l.postal_code = COALESCE(NULLIF(m.customer_postal_code, ''), '')
JOIN dim_pet_breed pb
    ON  pb.pet_type   = LOWER(TRIM(m.customer_pet_type))
    AND pb.breed_name = TRIM(m.customer_pet_breed)
WHERE m.customer_email IS NOT NULL AND m.customer_email != ''
ORDER BY m.customer_email
ON CONFLICT ON CONSTRAINT uq_customer_email DO NOTHING;


-- ----------------------------
-- 7. dim_seller
-- ----------------------------
INSERT INTO dim_seller (first_name, last_name, email, location_id)
SELECT DISTINCT ON (m.seller_email)
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    l.id
FROM mock_data m
JOIN dim_location l
    ON  l.country     = COALESCE(NULLIF(m.seller_country,     ''), '')
    AND l.city        = ''
    AND l.state       = ''
    AND l.postal_code = COALESCE(NULLIF(m.seller_postal_code, ''), '')
WHERE m.seller_email IS NOT NULL AND m.seller_email != ''
ORDER BY m.seller_email
ON CONFLICT ON CONSTRAINT uq_seller_email DO NOTHING;


-- ----------------------------
-- 8. dim_supplier
-- Берём первую запись для каждого уникального имени поставщика
-- ----------------------------
INSERT INTO dim_supplier (supplier_name, contact, email, phone, address, location_id)
SELECT DISTINCT ON (m.supplier_name)
    m.supplier_name,
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    m.supplier_address,
    l.id
FROM mock_data m
JOIN dim_location l
    ON  l.country     = COALESCE(NULLIF(m.supplier_country, ''), '')
    AND l.city        = COALESCE(NULLIF(m.supplier_city,    ''), '')
    AND l.state       = ''
    AND l.postal_code = ''
WHERE m.supplier_name IS NOT NULL AND m.supplier_name != ''
ORDER BY m.supplier_name
ON CONFLICT ON CONSTRAINT uq_supplier_name DO NOTHING;


-- ----------------------------
-- 9. dim_product
-- Уникальный товар = (product_name, brand)
-- Берём первую запись для каждой такой пары
-- ----------------------------
INSERT INTO dim_product (
    product_name, price, weight, color, size, material, description,
    rating, reviews, release_date, expiry_date,
    product_category_id, pet_category_id, brand_id, supplier_id
)
SELECT DISTINCT ON (m.product_name, m.product_brand)
    m.product_name,
    NULLIF(m.product_price,  '')::NUMERIC(10,2),
    NULLIF(m.product_weight, '')::NUMERIC(10,2),
    m.product_color,
    m.product_size,
    m.product_material,
    m.product_description,
    NULLIF(m.product_rating,  '')::NUMERIC(3,1),
    NULLIF(m.product_reviews, '')::INTEGER,
    CASE WHEN m.product_release_date != ''
         THEN TO_DATE(m.product_release_date, 'MM/DD/YYYY') END,
    CASE WHEN m.product_expiry_date != ''
         THEN TO_DATE(m.product_expiry_date,  'MM/DD/YYYY') END,
    pc.id,
    ptc.id,
    b.id,
    s.id
FROM mock_data m
JOIN dim_product_category pc  ON pc.category_name = TRIM(m.product_category)
JOIN dim_pet_category     ptc ON ptc.category_name = TRIM(m.pet_category)
JOIN dim_brand            b   ON b.brand_name      = TRIM(m.product_brand)
JOIN dim_supplier         s   ON s.supplier_name   = m.supplier_name
WHERE m.product_name IS NOT NULL AND m.product_name != ''
ORDER BY m.product_name, m.product_brand
ON CONFLICT ON CONSTRAINT uq_product DO NOTHING;


-- ----------------------------
-- 10. dim_store
-- Уникальный магазин = store_name
-- Берём первую запись для каждого названия магазина
-- ----------------------------
INSERT INTO dim_store (store_name, store_location, phone, email, location_id)
SELECT DISTINCT ON (m.store_name)
    m.store_name,
    m.store_location,
    m.store_phone,
    m.store_email,
    l.id
FROM mock_data m
JOIN dim_location l
    ON  l.country     = COALESCE(NULLIF(m.store_country, ''), '')
    AND l.city        = COALESCE(NULLIF(m.store_city,    ''), '')
    AND l.state       = COALESCE(NULLIF(m.store_state,   ''), '')
    AND l.postal_code = ''
WHERE m.store_name IS NOT NULL AND m.store_name != ''
ORDER BY m.store_name
ON CONFLICT ON CONSTRAINT uq_store DO NOTHING;


-- ----------------------------
-- 11. dim_date
-- ----------------------------
INSERT INTO dim_date (full_date, day, month, year, quarter, day_of_week)
SELECT DISTINCT
    TO_DATE(sale_date, 'MM/DD/YYYY')                                   AS full_date,
    EXTRACT(DAY     FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::SMALLINT   AS day,
    EXTRACT(MONTH   FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::SMALLINT   AS month,
    EXTRACT(YEAR    FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::SMALLINT   AS year,
    EXTRACT(QUARTER FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::SMALLINT   AS quarter,
    EXTRACT(DOW     FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::SMALLINT   AS day_of_week
FROM mock_data
WHERE sale_date IS NOT NULL AND sale_date != ''
ON CONFLICT ON CONSTRAINT uq_date DO NOTHING;
