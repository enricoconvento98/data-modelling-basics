-- 02_type1.sql
-- SCD Type 1: overwrite. The dimension keeps only the latest version.
-- History is lost: past sales are reported under the CURRENT city.

DROP TABLE IF EXISTS dim_customer_t1;

CREATE TABLE dim_customer_t1 AS
SELECT customer_id, customer_name, city
FROM (
    SELECT c.*,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY effective_date DESC) AS rn
    FROM customer_changes c
) latest
WHERE rn = 1;

SELECT * FROM dim_customer_t1 ORDER BY customer_id;

-- Sales by city with Type 1: Rome 150, Turin 70.
-- The January sale (made while Acme was in Milan) is now attributed to Rome.
SELECT 'type 1' AS scd, d.city, SUM(s.amount) AS amount
FROM sales s
JOIN dim_customer_t1 d ON d.customer_id = s.customer_id
GROUP BY d.city
ORDER BY d.city;
