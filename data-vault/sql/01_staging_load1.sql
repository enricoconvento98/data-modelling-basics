-- 01_staging_load1.sql
-- Staging area for the first load (a full extract from the source system).
-- Runs on DuckDB and PostgreSQL.
--
-- Same business as the other topics: one customer (Acme Ltd, Milan),
-- one order (freight 10) with three lines (20 + 30 + 50), three products.
-- load_meta holds the metadata that every raw vault row is stamped with.

DROP VIEW IF EXISTS mart_fact_order_line;
DROP VIEW IF EXISTS mart_fact_order;
DROP VIEW IF EXISTS mart_dim_product;
DROP VIEW IF EXISTS mart_dim_customer;
DROP TABLE IF EXISTS sat_order_line;
DROP TABLE IF EXISTS sat_order;
DROP TABLE IF EXISTS sat_product;
DROP TABLE IF EXISTS sat_customer;
DROP TABLE IF EXISTS link_order_line;
DROP TABLE IF EXISTS link_customer_order;
DROP TABLE IF EXISTS hub_product;
DROP TABLE IF EXISTS hub_order;
DROP TABLE IF EXISTS hub_customer;
DROP TABLE IF EXISTS stg_order_lines;
DROP TABLE IF EXISTS stg_orders;
DROP TABLE IF EXISTS stg_products;
DROP TABLE IF EXISTS stg_customers;
DROP TABLE IF EXISTS load_meta;

CREATE TABLE load_meta (
    load_dts      TIMESTAMP   NOT NULL,
    record_source VARCHAR(50) NOT NULL
);
INSERT INTO load_meta VALUES (TIMESTAMP '2024-01-31 00:00:00', 'shop_db');

CREATE TABLE stg_customers (
    customer_id   INTEGER,
    customer_name VARCHAR(50),
    city          VARCHAR(50)
);
CREATE TABLE stg_products (
    product_id   INTEGER,
    product_name VARCHAR(50)
);
CREATE TABLE stg_orders (
    order_id    INTEGER,
    customer_id INTEGER,
    order_date  DATE,
    freight     DECIMAL(10, 2)
);
CREATE TABLE stg_order_lines (
    line_id    INTEGER,
    order_id   INTEGER,
    product_id INTEGER,
    amount     DECIMAL(10, 2)
);

INSERT INTO stg_customers VALUES (1, 'Acme Ltd', 'Milan');
INSERT INTO stg_products  VALUES (1, 'Widget'), (2, 'Gadget'), (3, 'Gizmo');
INSERT INTO stg_orders    VALUES (100, 1, DATE '2024-01-15', 10.00);
INSERT INTO stg_order_lines VALUES
    (1001, 100, 1, 20.00),
    (1002, 100, 2, 30.00),
    (1003, 100, 1, 50.00);
