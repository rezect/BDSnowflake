-- =============================================================
-- 01_ddl_dimensions.sql
-- DDL таблиц-измерений — схема «Снежинка»
-- =============================================================

-- ----------------------------
-- Общее местоположение
-- Используется для: customer, seller, store, supplier
-- ----------------------------
CREATE TABLE dim_location (
    id          SERIAL PRIMARY KEY,
    country     VARCHAR(100) NOT NULL DEFAULT '',
    city        VARCHAR(100) NOT NULL DEFAULT '',
    state       VARCHAR(100) NOT NULL DEFAULT '',
    postal_code VARCHAR(50)  NOT NULL DEFAULT '',
    CONSTRAINT uq_location UNIQUE (country, city, state, postal_code)
);

-- ----------------------------
-- Порода питомца (нормализация customer)
-- ----------------------------
CREATE TABLE dim_pet_breed (
    id         SERIAL PRIMARY KEY,
    pet_type   VARCHAR(50)  NOT NULL,
    breed_name VARCHAR(100) NOT NULL,
    CONSTRAINT uq_pet_breed UNIQUE (pet_type, breed_name)
);

-- ----------------------------
-- Категория питомца (Birds, Cats, Dogs, Fish, Reptiles)
-- ----------------------------
CREATE TABLE dim_pet_category (
    id            SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    CONSTRAINT uq_pet_category UNIQUE (category_name)
);

-- ----------------------------
-- Категория товара (Food, Toy, Cage)
-- ----------------------------
CREATE TABLE dim_product_category (
    id            SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    CONSTRAINT uq_product_category UNIQUE (category_name)
);

-- ----------------------------
-- Бренд товара
-- ----------------------------
CREATE TABLE dim_brand (
    id         SERIAL PRIMARY KEY,
    brand_name VARCHAR(200) NOT NULL,
    CONSTRAINT uq_brand UNIQUE (brand_name)
);

-- ----------------------------
-- Покупатель
-- Зависит от: dim_location, dim_pet_breed
-- ----------------------------
CREATE TABLE dim_customer (
    id           SERIAL PRIMARY KEY,
    first_name   VARCHAR(100),
    last_name    VARCHAR(100),
    age          INTEGER,
    email        VARCHAR(200) NOT NULL,
    pet_name     VARCHAR(100),
    location_id  INTEGER NOT NULL REFERENCES dim_location(id),
    pet_breed_id INTEGER NOT NULL REFERENCES dim_pet_breed(id),
    CONSTRAINT uq_customer_email UNIQUE (email)
);

-- ----------------------------
-- Продавец
-- Зависит от: dim_location
-- ----------------------------
CREATE TABLE dim_seller (
    id          SERIAL PRIMARY KEY,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    email       VARCHAR(200) NOT NULL,
    location_id INTEGER NOT NULL REFERENCES dim_location(id),
    CONSTRAINT uq_seller_email UNIQUE (email)
);

-- ----------------------------
-- Поставщик
-- Зависит от: dim_location
-- ----------------------------
CREATE TABLE dim_supplier (
    id           SERIAL PRIMARY KEY,
    supplier_name VARCHAR(200) NOT NULL,
    contact      VARCHAR(200),
    email        VARCHAR(200),
    phone        VARCHAR(50),
    address      VARCHAR(200),
    location_id  INTEGER NOT NULL REFERENCES dim_location(id),
    CONSTRAINT uq_supplier_name UNIQUE (supplier_name)
);

-- ----------------------------
-- Товар
-- Зависит от: dim_product_category, dim_pet_category, dim_brand, dim_supplier
-- ----------------------------
CREATE TABLE dim_product (
    id                  SERIAL PRIMARY KEY,
    product_name        VARCHAR(200) NOT NULL,
    price               NUMERIC(10,2),
    weight              NUMERIC(10,2),
    color               VARCHAR(100),
    size                VARCHAR(50),
    material            VARCHAR(100),
    description         TEXT,
    rating              NUMERIC(3,1),
    reviews             INTEGER,
    release_date        DATE,
    expiry_date         DATE,
    product_category_id INTEGER NOT NULL REFERENCES dim_product_category(id),
    pet_category_id     INTEGER NOT NULL REFERENCES dim_pet_category(id),
    brand_id            INTEGER NOT NULL REFERENCES dim_brand(id),
    supplier_id         INTEGER NOT NULL REFERENCES dim_supplier(id),
    CONSTRAINT uq_product UNIQUE (product_name, brand_id)
);

-- ----------------------------
-- Магазин
-- Зависит от: dim_location
-- ----------------------------
CREATE TABLE dim_store (
    id             SERIAL PRIMARY KEY,
    store_name     VARCHAR(200) NOT NULL,
    store_location VARCHAR(200),
    phone          VARCHAR(50),
    email          VARCHAR(200),
    location_id    INTEGER NOT NULL REFERENCES dim_location(id),
    CONSTRAINT uq_store UNIQUE (store_name)
);

-- ----------------------------
-- Дата (для аналитики)
-- ----------------------------
CREATE TABLE dim_date (
    id           SERIAL PRIMARY KEY,
    full_date    DATE        NOT NULL,
    day          SMALLINT    NOT NULL,
    month        SMALLINT    NOT NULL,
    year         SMALLINT    NOT NULL,
    quarter      SMALLINT    NOT NULL,
    day_of_week  SMALLINT    NOT NULL,  -- 0=Sun, 6=Sat
    CONSTRAINT uq_date UNIQUE (full_date)
);
