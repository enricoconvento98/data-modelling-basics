-- 04_type3_type6.sql
-- SCD Type 3: add a column for the previous value (limited history).
-- SCD Type 6: Type 2 rows + a Type 1 "current" column on every version
--             (1 + 2 + 3 = 6), so you can report by historical OR current value.

DROP TABLE IF EXISTS dim_customer_t3;
DROP TABLE IF EXISTS dim_customer_t6;

-- Type 3: one row per customer, current and previous city side by side.
CREATE TABLE dim_customer_t3 AS
SELECT customer_id, customer_name, city AS current_city, previous_city
FROM (
    SELECT c.*,
           LAG(city) OVER (PARTITION BY customer_id ORDER BY effective_date) AS previous_city,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY effective_date DESC) AS rn
    FROM customer_changes c
) x
WHERE rn = 1;

SELECT * FROM dim_customer_t3 ORDER BY customer_id;

-- Type 6: every Type 2 version also carries the customer's current city.
CREATE TABLE dim_customer_t6 AS
SELECT d.*,
       cur.city AS current_city
FROM dim_customer_t2 d
JOIN dim_customer_t2 cur
  ON cur.customer_id = d.customer_id
 AND cur.is_current;

SELECT customer_sk, customer_id, city AS historical_city, current_city, valid_from, valid_to
FROM dim_customer_t6
ORDER BY customer_id, valid_from;

-- One fact table, two views of history, no extra join:
--   historical_city: Milan 100, Rome 50, Turin 70
--   current_city   : Rome 150, Turin 70
SELECT 'historical' AS perspective, d.city AS city, SUM(f.amount) AS amount
FROM fact_sales f JOIN dim_customer_t6 d ON d.customer_sk = f.customer_sk
GROUP BY d.city
UNION ALL
SELECT 'current', d.current_city, SUM(f.amount)
FROM fact_sales f JOIN dim_customer_t6 d ON d.customer_sk = f.customer_sk
GROUP BY d.current_city
ORDER BY perspective, city;
