-- 03_bridge.sql
-- The Puppini Bridge (_bridge): one UNION ALL "stage" per source table.
--
-- Each stage row carries:
--   * its own key,
--   * every key reachable from it by following many-to-one links
--     (order_lines -> orders -> customers, order_lines -> products, ...),
--   * the measures that belong to that table, and NULL for all others.
--
-- Keys/measures not applicable to a stage are typed NULLs so the UNION ALL
-- is portable between DuckDB and PostgreSQL.

DROP TABLE IF EXISTS _bridge;

CREATE TABLE _bridge AS
-- Stage: customers (no outgoing many-to-one links, no measures)
SELECT 'customers'                 AS stage,
       c.customer_id               AS _key_customer,
       CAST(NULL AS INTEGER)       AS _key_order,
       CAST(NULL AS INTEGER)       AS _key_line,
       CAST(NULL AS INTEGER)       AS _key_product,
       CAST(NULL AS INTEGER)       AS _key_shipment,
       CAST(NULL AS DECIMAL(10,2)) AS freight,
       CAST(NULL AS DECIMAL(10,2)) AS amount,
       CAST(NULL AS DECIMAL(10,2)) AS ship_cost
FROM customers c

UNION ALL
-- Stage: orders -> customers
SELECT 'orders',
       o.customer_id,
       o.order_id,
       CAST(NULL AS INTEGER),
       CAST(NULL AS INTEGER),
       CAST(NULL AS INTEGER),
       o.freight,
       CAST(NULL AS DECIMAL(10,2)),
       CAST(NULL AS DECIMAL(10,2))
FROM orders o

UNION ALL
-- Stage: order_lines -> orders -> customers, order_lines -> products
SELECT 'order_lines',
       o.customer_id,
       l.order_id,
       l.line_id,
       l.product_id,
       CAST(NULL AS INTEGER),
       CAST(NULL AS DECIMAL(10,2)),
       l.amount,
       CAST(NULL AS DECIMAL(10,2))
FROM order_lines l
JOIN orders o ON o.order_id = l.order_id   -- many-to-one: cannot fan out

UNION ALL
-- Stage: products (no outgoing many-to-one links, no measures)
SELECT 'products',
       CAST(NULL AS INTEGER),
       CAST(NULL AS INTEGER),
       CAST(NULL AS INTEGER),
       p.product_id,
       CAST(NULL AS INTEGER),
       CAST(NULL AS DECIMAL(10,2)),
       CAST(NULL AS DECIMAL(10,2)),
       CAST(NULL AS DECIMAL(10,2))
FROM products p

UNION ALL
-- Stage: shipments -> customers
SELECT 'shipments',
       s.customer_id,
       CAST(NULL AS INTEGER),
       CAST(NULL AS INTEGER),
       CAST(NULL AS INTEGER),
       s.shipment_id,
       CAST(NULL AS DECIMAL(10,2)),
       CAST(NULL AS DECIMAL(10,2)),
       s.ship_cost
FROM shipments s;

-- Show the bridge contents.
SELECT *
FROM _bridge
ORDER BY CASE stage
             WHEN 'customers'   THEN 1
             WHEN 'orders'      THEN 2
             WHEN 'order_lines' THEN 3
             WHEN 'products'    THEN 4
             WHEN 'shipments'   THEN 5
         END,
         _key_customer, _key_order, _key_line, _key_product, _key_shipment;
