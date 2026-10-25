-- 02_naive_joins.sql
-- Naive joins across the source tables. Every total below is WRONG.
-- Correct totals are: freight = 10, amount = 100, ship_cost = 12.

-- Fan trap: orders 1──* order_lines.
-- The single order row is repeated once per line, so its freight is
-- counted 3 times (30 instead of 10). amount is still correct (100).
SELECT 'fan trap' AS query,
       SUM(o.freight) AS freight,     -- 30  (should be 10)
       SUM(l.amount)  AS amount       -- 100 (correct)
FROM orders o
JOIN order_lines l ON l.order_id = o.order_id;

-- Chasm trap: shipments *──1 customers 1──* orders.
-- Orders and shipments are independent of each other, so joining both to the
-- customer produces their cartesian product (1 order x 2 shipments = 2 rows).
SELECT 'chasm trap' AS query,
       SUM(o.freight)   AS freight,   -- 20 (should be 10)
       SUM(s.ship_cost) AS ship_cost  -- 12 (correct only because there is 1 order)
FROM customers c
JOIN orders    o ON o.customer_id = c.customer_id
JOIN shipments s ON s.customer_id = c.customer_id;

-- Both traps at once: 3 lines x 2 shipments = 6 rows per customer.
SELECT 'fan + chasm' AS query,
       c.customer_name,
       SUM(o.freight)   AS freight,   -- 60  (should be 10)
       SUM(l.amount)    AS amount,    -- 200 (should be 100)
       SUM(s.ship_cost) AS ship_cost  -- 36  (should be 12)
FROM customers   c
JOIN orders      o ON o.customer_id = c.customer_id
JOIN order_lines l ON l.order_id    = o.order_id
JOIN shipments   s ON s.customer_id = c.customer_id
GROUP BY c.customer_name;
