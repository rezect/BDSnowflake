-- =============================================================
-- 04_dml_facts.sql
-- Заполнение таблицы фактов fact_sales из mock_data
-- Каждая строка mock_data — одна транзакция продажи
-- =============================================================

INSERT INTO fact_sales (date_id, customer_id, seller_id, product_id, store_id, quantity, total_price)
SELECT
    dd.id                              AS date_id,
    dc.id                              AS customer_id,
    ds.id                              AS seller_id,
    dp.id                              AS product_id,
    dstore.id                          AS store_id,
    NULLIF(m.sale_quantity,   '')::INTEGER      AS quantity,
    NULLIF(m.sale_total_price,'')::NUMERIC(10,2) AS total_price
FROM mock_data m

-- Дата
JOIN dim_date dd
    ON dd.full_date = TO_DATE(m.sale_date, 'MM/DD/YYYY')

-- Покупатель
JOIN dim_customer dc
    ON dc.email = m.customer_email

-- Продавец
JOIN dim_seller ds
    ON ds.email = m.seller_email

-- Товар: по имени и бренду
JOIN dim_brand b
    ON b.brand_name = TRIM(m.product_brand)
JOIN dim_product dp
    ON dp.product_name = m.product_name
   AND dp.brand_id     = b.id

-- Магазин
JOIN dim_store dstore
    ON dstore.store_name = m.store_name

WHERE m.sale_date        IS NOT NULL AND m.sale_date        != ''
  AND m.customer_email   IS NOT NULL AND m.customer_email   != ''
  AND m.seller_email     IS NOT NULL AND m.seller_email     != ''
  AND m.product_name     IS NOT NULL AND m.product_name     != ''
  AND m.store_name       IS NOT NULL AND m.store_name       != '';
