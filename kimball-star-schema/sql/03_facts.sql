-- 03_facts.sql
-- One fact table per grain. Never mix grains in a single fact table.
--
--   fact_order_line : one row per order line  (amount, freight_allocated)
--   fact_order      : one row per order       (freight)
--   fact_shipment   : one row per shipment    (ship_cost)

DROP TABLE IF EXISTS fact_order_line;
DROP TABLE IF EXISTS fact_order;
DROP TABLE IF EXISTS fact_shipment;

-- Line grain. Order-level freight is ALLOCATED down to the lines in proportion
-- to amount, so it can be summed at line grain without double counting
-- (10 * 20/100 = 2, 10 * 30/100 = 3, 10 * 50/100 = 5).
CREATE TABLE fact_order_line AS
SELECT d.date_key,
       c.customer_key,
       p.product_key,
       l.order_id,                                    -- degenerate dimension
       l.line_id,
       l.amount,
       CAST(o.freight * l.amount / SUM(l.amount) OVER (PARTITION BY l.order_id)
            AS DECIMAL(10, 2)) AS freight_allocated
FROM order_lines l
JOIN orders       o ON o.order_id    = l.order_id
JOIN dim_customer c ON c.customer_id = o.customer_id
JOIN dim_product  p ON p.product_id  = l.product_id
JOIN dim_date     d ON d.full_date   = o.order_date;

-- Order (header) grain: the alternative to allocation.
CREATE TABLE fact_order AS
SELECT d.date_key,
       c.customer_key,
       o.order_id,
       o.freight
FROM orders o
JOIN dim_customer c ON c.customer_id = o.customer_id
JOIN dim_date     d ON d.full_date   = o.order_date;

-- Shipment grain: a different business process.
CREATE TABLE fact_shipment AS
SELECT d.date_key,
       c.customer_key,
       s.shipment_id,                                 -- degenerate dimension
       s.ship_cost
FROM shipments s
JOIN dim_customer c ON c.customer_id = s.customer_id
JOIN dim_date     d ON d.full_date   = s.ship_date;

SELECT * FROM fact_order_line ORDER BY line_id;
SELECT * FROM fact_order      ORDER BY order_id;
SELECT * FROM fact_shipment   ORDER BY shipment_id;
