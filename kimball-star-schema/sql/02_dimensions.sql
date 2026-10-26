-- 02_dimensions.sql
-- Conformed dimensions shared by every fact table.
-- Each dimension gets a surrogate key (*_key) independent of the source key.

DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_customer AS
SELECT CAST(ROW_NUMBER() OVER (ORDER BY customer_id) AS INTEGER) AS customer_key,
       customer_id,                                   -- natural / business key
       customer_name
FROM customers;

CREATE TABLE dim_product AS
SELECT CAST(ROW_NUMBER() OVER (ORDER BY product_id) AS INTEGER) AS product_key,
       product_id,
       product_name
FROM products;

-- Date dimension for 2024, one row per day, smart key yyyymmdd.
CREATE TABLE dim_date AS
SELECT CAST(EXTRACT(YEAR  FROM d) * 10000
          + EXTRACT(MONTH FROM d) * 100
          + EXTRACT(DAY   FROM d) AS INTEGER)            AS date_key,
       d                                                 AS full_date,
       CAST(EXTRACT(YEAR  FROM d) AS INTEGER)            AS year,
       CAST(EXTRACT(MONTH FROM d) AS INTEGER)            AS month,
       CAST(EXTRACT(YEAR FROM d) AS VARCHAR) || '-'
         || LPAD(CAST(CAST(EXTRACT(MONTH FROM d) AS INTEGER) AS VARCHAR), 2, '0')
                                                         AS year_month
FROM (
    SELECT CAST(g AS DATE) AS d
    FROM generate_series(TIMESTAMP '2024-01-01', TIMESTAMP '2024-12-31', INTERVAL '1 day') AS t(g)
) days;

SELECT 'dim_customer' AS dimension, COUNT(*) AS row_count FROM dim_customer
UNION ALL SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_date',    COUNT(*) FROM dim_date;
