-- =============================================================
-- 02_ddl_facts.sql
-- DDL таблицы фактов продаж
-- =============================================================

CREATE TABLE fact_sales (
    id          SERIAL PRIMARY KEY,
    date_id     INTEGER NOT NULL REFERENCES dim_date(id),
    customer_id INTEGER NOT NULL REFERENCES dim_customer(id),
    seller_id   INTEGER NOT NULL REFERENCES dim_seller(id),
    product_id  INTEGER NOT NULL REFERENCES dim_product(id),
    store_id    INTEGER NOT NULL REFERENCES dim_store(id),
    quantity    INTEGER      NOT NULL,
    total_price NUMERIC(10,2) NOT NULL
);

-- Индексы для ускорения аналитических запросов
CREATE INDEX idx_fact_sales_date     ON fact_sales(date_id);
CREATE INDEX idx_fact_sales_customer ON fact_sales(customer_id);
CREATE INDEX idx_fact_sales_seller   ON fact_sales(seller_id);
CREATE INDEX idx_fact_sales_product  ON fact_sales(product_id);
CREATE INDEX idx_fact_sales_store    ON fact_sales(store_id);
