-- 04_queries.sql
-- Querying the star schema. Correct totals: freight 10, amount 100, ship_cost 12.

-- WRONG #1 -- mixed grain: copying order-level freight onto each line row
-- brings the fan trap back (freight 30).
SELECT 'mixed grain (wrong)' AS query,
       SUM(o.freight)  AS freight,
       SUM(f.amount)   AS amount
FROM fact_order_line f
JOIN orders o ON o.order_id = f.order_id;

-- WRONG #2 -- joining two fact tables directly: fact-to-fact through a shared
-- dimension key is the chasm trap (3 lines x 2 shipments = 6 rows).
SELECT 'fact-to-fact join (wrong)' AS query,
       SUM(l.amount)    AS amount,     -- 200
       SUM(s.ship_cost) AS ship_cost   -- 36
FROM fact_order_line l
JOIN fact_shipment   s ON s.customer_key = l.customer_key;

-- RIGHT -- drill-across: aggregate each fact table separately to a common
-- grain of CONFORMED dimensions, then join the small result sets.
WITH lines AS (
    SELECT customer_key, SUM(amount) AS amount, SUM(freight_allocated) AS freight_allocated
    FROM fact_order_line GROUP BY customer_key
), ords AS (
    SELECT customer_key, SUM(freight) AS freight
    FROM fact_order GROUP BY customer_key
), ships AS (
    SELECT customer_key, SUM(ship_cost) AS ship_cost
    FROM fact_shipment GROUP BY customer_key
)
SELECT c.customer_name,
       o.freight,              -- 10 (order grain)
       l.freight_allocated,    -- 10 (allocated to lines)
       l.amount,               -- 100
       s.ship_cost             -- 12
FROM dim_customer c
LEFT JOIN lines l ON l.customer_key = c.customer_key
LEFT JOIN ords  o ON o.customer_key = c.customer_key
LEFT JOIN ships s ON s.customer_key = c.customer_key
ORDER BY c.customer_name;

-- Drill-across by month through the conformed date dimension.
-- Orders use order_date, shipments use ship_date: each fact brings its own date.
WITH lines AS (
    SELECT d.year_month, SUM(f.amount) AS amount
    FROM fact_order_line f JOIN dim_date d ON d.date_key = f.date_key
    GROUP BY d.year_month
), ords AS (
    SELECT d.year_month, SUM(f.freight) AS freight
    FROM fact_order f JOIN dim_date d ON d.date_key = f.date_key
    GROUP BY d.year_month
), ships AS (
    SELECT d.year_month, SUM(f.ship_cost) AS ship_cost
    FROM fact_shipment f JOIN dim_date d ON d.date_key = f.date_key
    GROUP BY d.year_month
), months AS (
    SELECT year_month FROM lines
    UNION SELECT year_month FROM ords
    UNION SELECT year_month FROM ships
)
SELECT m.year_month, o.freight, l.amount, s.ship_cost
FROM months m
LEFT JOIN lines l ON l.year_month = m.year_month
LEFT JOIN ords  o ON o.year_month = m.year_month
LEFT JOIN ships s ON s.year_month = m.year_month
ORDER BY m.year_month;

-- By product: thanks to allocation, freight can be split by product
-- (Widget 7, Gadget 3). Compare with the USS, where it lands on a NULL product.
SELECT p.product_name,
       SUM(f.amount)            AS amount,
       SUM(f.freight_allocated) AS freight_allocated
FROM fact_order_line f
JOIN dim_product p ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY p.product_name;

-- Products never sold: start from the dimension, anti-join the fact.
SELECT p.product_id, p.product_name
FROM dim_product p
LEFT JOIN fact_order_line f ON f.product_key = p.product_key
WHERE f.product_key IS NULL
ORDER BY p.product_id;
