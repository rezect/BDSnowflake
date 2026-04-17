-- =============================================================
-- 00_raw.sql
-- Создание сырой (staging) таблицы и загрузка 10 CSV-файлов
-- =============================================================

CREATE TABLE IF NOT EXISTS mock_data (
    id                  INTEGER,
    customer_first_name VARCHAR(100),
    customer_last_name  VARCHAR(100),
    customer_age        VARCHAR(10),
    customer_email      VARCHAR(200),
    customer_country    VARCHAR(100),
    customer_postal_code VARCHAR(50),
    customer_pet_type   VARCHAR(50),
    customer_pet_name   VARCHAR(100),
    customer_pet_breed  VARCHAR(100),
    seller_first_name   VARCHAR(100),
    seller_last_name    VARCHAR(100),
    seller_email        VARCHAR(200),
    seller_country      VARCHAR(100),
    seller_postal_code  VARCHAR(50),
    product_name        VARCHAR(200),
    product_category    VARCHAR(100),
    product_price       VARCHAR(20),
    product_quantity    VARCHAR(10),
    sale_date           VARCHAR(20),
    sale_customer_id    VARCHAR(10),
    sale_seller_id      VARCHAR(10),
    sale_product_id     VARCHAR(10),
    sale_quantity       VARCHAR(10),
    sale_total_price    VARCHAR(20),
    store_name          VARCHAR(200),
    store_location      VARCHAR(200),
    store_city          VARCHAR(100),
    store_state         VARCHAR(100),
    store_country       VARCHAR(100),
    store_phone         VARCHAR(50),
    store_email         VARCHAR(200),
    pet_category        VARCHAR(100),
    product_weight      VARCHAR(20),
    product_color       VARCHAR(100),
    product_size        VARCHAR(50),
    product_brand       VARCHAR(200),
    product_material    VARCHAR(100),
    product_description TEXT,
    product_rating      VARCHAR(10),
    product_reviews     VARCHAR(10),
    product_release_date VARCHAR(20),
    product_expiry_date  VARCHAR(20),
    supplier_name       VARCHAR(200),
    supplier_contact    VARCHAR(200),
    supplier_email      VARCHAR(200),
    supplier_phone      VARCHAR(50),
    supplier_address    VARCHAR(200),
    supplier_city       VARCHAR(100),
    supplier_country    VARCHAR(100)
);

-- Загрузка 10 файлов (переименуйте файлы согласно README)
COPY mock_data FROM '/data/MOCK_DATA_1.csv'  DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA_2.csv'  DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA_3.csv'  DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA_4.csv'  DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA_5.csv'  DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA_6.csv'  DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA_7.csv'  DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA_8.csv'  DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA_9.csv'  DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA_10.csv' DELIMITER ',' CSV HEADER;
