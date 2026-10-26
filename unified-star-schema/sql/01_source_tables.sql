-- 01_source_tables.sql
-- Source (normalised) model used throughout the Unified Star Schema example.
-- Runs on DuckDB and PostgreSQL.
--
--   customers 1──* orders 1──* order_lines *──1 products
--   customers 1──* shipments
--
-- Sample data: one customer with 1 order (freight 10), 3 order lines
-- (amount 20 + 30 + 50 = 100), 2 shipments (ship_cost 5 + 7 = 12),
-- and one product that has never been sold.

DROP TABLE IF EXISTS _bridge;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS order_lines;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id   INTEGER PRIMARY KEY,
    customer_name VARCHAR(50) NOT NULL
);

CREATE TABLE products (
    product_id   INTEGER PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL
);

CREATE TABLE orders (
    order_id    INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers (customer_id),
    order_date  DATE NOT NULL,
    freight     DECIMAL(10, 2) NOT NULL   -- order-level measure
);

CREATE TABLE order_lines (
    line_id    INTEGER PRIMARY KEY,
    order_id   INTEGER NOT NULL REFERENCES orders (order_id),
    product_id INTEGER NOT NULL REFERENCES products (product_id),
    amount     DECIMAL(10, 2) NOT NULL    -- line-level measure
);

CREATE TABLE shipments (
    shipment_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers (customer_id),
    ship_date   DATE NOT NULL,
    ship_cost   DECIMAL(10, 2) NOT NULL   -- shipment-level measure
);

INSERT INTO customers VALUES
    (1, 'Acme Ltd');

INSERT INTO products VALUES
    (1, 'Widget'),
    (2, 'Gadget'),
    (3, 'Gizmo');          -- never sold

INSERT INTO orders VALUES
    (100, 1, DATE '2024-01-15', 10.00);

INSERT INTO order_lines VALUES
    (1001, 100, 1, 20.00),
    (1002, 100, 2, 30.00),
    (1003, 100, 1, 50.00);

INSERT INTO shipments VALUES
    (501, 1, DATE '2024-01-16', 5.00),
    (502, 1, DATE '2024-01-18', 7.00);
