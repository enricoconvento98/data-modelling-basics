-- 03_type2.sql
-- SCD Type 2: add a new row per version, with a validity interval.
--   customer_sk : surrogate key, one per VERSION (facts point to this)
--   customer_id : natural key, the same for all versions of a customer
--   valid_from / valid_to : half-open interval [valid_from, valid_to)
--   is_current  : convenience flag for the latest version

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_customer_t2;

CREATE TABLE dim_customer_t2 AS
SELECT CAST(ROW_NUMBER() OVER (ORDER BY customer_id, effective_date) AS INTEGER) AS customer_sk,
       customer_id,
       customer_name,
       city,
       effective_date AS valid_from,
       COALESCE(LEAD(effective_date) OVER (PARTITION BY customer_id ORDER BY effective_date),
                DATE '9999-12-31') AS valid_to,
       LEAD(effective_date) OVER (PARTITION BY customer_id ORDER BY effective_date) IS NULL
           AS is_current
FROM customer_changes;

SELECT * FROM dim_customer_t2 ORDER BY customer_id, valid_from;

-- The fact table stores the surrogate key of the version that was valid
-- on the date of the sale (the "point-in-time lookup").
CREATE TABLE fact_sales AS
SELECT s.sale_id,
       d.customer_sk,
       s.sale_date,
       s.amount
FROM sales s
JOIN dim_customer_t2 d
  ON d.customer_id = s.customer_id
 AND s.sale_date >= d.valid_from
 AND s.sale_date <  d.valid_to;

SELECT * FROM fact_sales ORDER BY sale_id;

-- Sales by city AS IT WAS at the time of the sale: Milan 100, Rome 50, Turin 70.
SELECT 'type 2' AS scd, d.city, SUM(f.amount) AS amount
FROM fact_sales f
JOIN dim_customer_t2 d ON d.customer_sk = f.customer_sk
GROUP BY d.city
ORDER BY d.city;

-- Count customers, not versions: use the natural key.
SELECT COUNT(*) AS versions, COUNT(DISTINCT customer_id) AS customers
FROM dim_customer_t2;

-- "As of" query: what did the dimension look like on 2024-02-15?
SELECT customer_id, customer_name, city
FROM dim_customer_t2
WHERE DATE '2024-02-15' >= valid_from
  AND DATE '2024-02-15' <  valid_to
ORDER BY customer_id;
