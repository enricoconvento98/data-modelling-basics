-- 01_source.sql
-- Source data for the Slowly Changing Dimensions examples.
-- Runs on DuckDB and PostgreSQL.
--
-- customer_changes is a change log: one row per version of a customer,
-- with the date the version became effective.
--   * Acme Ltd starts in Milan and moves to Rome on 2024-03-01.
--   * Beta Srl stays in Turin.
-- sales happen over time, before and after Acme's move:
--   Acme  2024-01-20  100  (customer was in Milan)
--   Beta  2024-02-10   70  (Turin)
--   Acme  2024-04-05   50  (customer was in Rome)

DROP TABLE IF EXISTS change_batch;
DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_customer_t6;
DROP TABLE IF EXISTS dim_customer_t3;
DROP TABLE IF EXISTS dim_customer_t2;
DROP TABLE IF EXISTS dim_customer_t1;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS customer_changes;

CREATE TABLE customer_changes (
    customer_id    INTEGER     NOT NULL,
    customer_name  VARCHAR(50) NOT NULL,
    city           VARCHAR(50) NOT NULL,
    effective_date DATE        NOT NULL,
    PRIMARY KEY (customer_id, effective_date)
);

CREATE TABLE sales (
    sale_id     INTEGER PRIMARY KEY,
    customer_id INTEGER        NOT NULL,
    sale_date   DATE           NOT NULL,
    amount      DECIMAL(10, 2) NOT NULL
);

INSERT INTO customer_changes VALUES
    (1, 'Acme Ltd', 'Milan', DATE '2024-01-01'),
    (2, 'Beta Srl', 'Turin', DATE '2024-01-01'),
    (1, 'Acme Ltd', 'Rome',  DATE '2024-03-01');

INSERT INTO sales VALUES
    (1, 1, DATE '2024-01-20', 100.00),
    (2, 2, DATE '2024-02-10',  70.00),
    (3, 1, DATE '2024-04-05',  50.00);
