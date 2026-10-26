-- 04_uss_queries.sql
-- Queries through the Unified Star Schema.
-- Rule: always start FROM _bridge and LEFT JOIN each table on its own key.
-- No table is ever joined to another table, so nothing can fan out.

-- Totals by customer: freight 10, amount 100, ship_cost 12.
SELECT c.customer_name,
       SUM(b.freight)   AS freight,
       SUM(b.amount)    AS amount,
       SUM(b.ship_cost) AS ship_cost
FROM _bridge b
LEFT JOIN customers c ON c.customer_id = b._key_customer
WHERE c.customer_id IS NOT NULL
GROUP BY c.customer_name
ORDER BY c.customer_name;

-- Grand totals straight from the bridge (no joins at all).
SELECT SUM(freight)   AS freight,
       SUM(amount)    AS amount,
       SUM(ship_cost) AS ship_cost
FROM _bridge;

-- Totals by product. Line amounts split across products (Widget 70,
-- Gadget 30, Gizmo 0). Freight and ship_cost do not belong to any product,
-- so they land on the NULL ("not applicable") product row instead of being
-- duplicated -- the grand total still adds up.
SELECT COALESCE(p.product_name, '(no product)') AS product_name,
       COALESCE(SUM(b.amount), 0)    AS amount,
       COALESCE(SUM(b.freight), 0)   AS freight,
       COALESCE(SUM(b.ship_cost), 0) AS ship_cost
FROM _bridge b
LEFT JOIN products p ON p.product_id = b._key_product
GROUP BY p.product_name
ORDER BY p.product_name NULLS LAST;

-- Customer and product in the same query: both tables hang off the bridge.
SELECT c.customer_name,
       p.product_name,
       SUM(b.amount) AS amount
FROM _bridge b
LEFT JOIN customers c ON c.customer_id = b._key_customer
LEFT JOIN products  p ON p.product_id  = b._key_product
WHERE b.stage = 'order_lines'
GROUP BY c.customer_name, p.product_name
ORDER BY c.customer_name, p.product_name;

-- Products never sold: every product has a row on the 'products' stage,
-- so it is present in the bridge even with no order lines.
SELECT p.product_id,
       p.product_name
FROM _bridge b
LEFT JOIN products p ON p.product_id = b._key_product
WHERE b._key_product IS NOT NULL
GROUP BY p.product_id, p.product_name
HAVING COUNT(b._key_line) = 0
ORDER BY p.product_id;
