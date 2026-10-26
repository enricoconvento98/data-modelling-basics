-- 03_load_raw_vault.sql
-- Loads the current staging contents into the raw vault.
-- Idempotent and insert-only: run it after every staging load, run it twice,
-- the result is the same.
--   * hubs/links: insert keys not seen before
--   * satellites: insert a new row only when hash_diff differs from the
--     latest row for that key (i.e. something actually changed)
-- Hubs are loaded before links, links before their satellites.

-- Hubs ----------------------------------------------------------------------
INSERT INTO hub_customer
SELECT DISTINCT md5(CAST(s.customer_id AS VARCHAR)), s.customer_id, m.load_dts, m.record_source
FROM stg_customers s CROSS JOIN load_meta m
WHERE NOT EXISTS (SELECT 1 FROM hub_customer h WHERE h.customer_id = s.customer_id);

INSERT INTO hub_product
SELECT DISTINCT md5(CAST(s.product_id AS VARCHAR)), s.product_id, m.load_dts, m.record_source
FROM stg_products s CROSS JOIN load_meta m
WHERE NOT EXISTS (SELECT 1 FROM hub_product h WHERE h.product_id = s.product_id);

INSERT INTO hub_order
SELECT DISTINCT md5(CAST(s.order_id AS VARCHAR)), s.order_id, m.load_dts, m.record_source
FROM stg_orders s CROSS JOIN load_meta m
WHERE NOT EXISTS (SELECT 1 FROM hub_order h WHERE h.order_id = s.order_id);

-- Links ---------------------------------------------------------------------
INSERT INTO link_customer_order
SELECT DISTINCT
       md5(CAST(s.customer_id AS VARCHAR) || '||' || CAST(s.order_id AS VARCHAR)),
       md5(CAST(s.customer_id AS VARCHAR)),
       md5(CAST(s.order_id AS VARCHAR)),
       m.load_dts, m.record_source
FROM stg_orders s CROSS JOIN load_meta m
WHERE NOT EXISTS (
    SELECT 1 FROM link_customer_order l
    WHERE l.customer_order_hk = md5(CAST(s.customer_id AS VARCHAR) || '||' || CAST(s.order_id AS VARCHAR))
);

INSERT INTO link_order_line
SELECT DISTINCT
       md5(CAST(s.order_id AS VARCHAR) || '||' || CAST(s.product_id AS VARCHAR) || '||' || CAST(s.line_id AS VARCHAR)),
       md5(CAST(s.order_id AS VARCHAR)),
       md5(CAST(s.product_id AS VARCHAR)),
       s.line_id,
       m.load_dts, m.record_source
FROM stg_order_lines s CROSS JOIN load_meta m
WHERE NOT EXISTS (
    SELECT 1 FROM link_order_line l
    WHERE l.order_line_hk = md5(CAST(s.order_id AS VARCHAR) || '||' || CAST(s.product_id AS VARCHAR) || '||' || CAST(s.line_id AS VARCHAR))
);

-- Satellites ----------------------------------------------------------------
INSERT INTO sat_customer
SELECT s.hk, m.load_dts, s.hash_diff, s.customer_name, s.city, m.record_source
FROM (
    SELECT md5(CAST(customer_id AS VARCHAR)) AS hk,
           md5(COALESCE(customer_name, '') || '||' || COALESCE(city, '')) AS hash_diff,
           customer_name, city
    FROM stg_customers
) s
CROSS JOIN load_meta m
LEFT JOIN (
    SELECT customer_hk, hash_diff,
           ROW_NUMBER() OVER (PARTITION BY customer_hk ORDER BY load_dts DESC) AS rn
    FROM sat_customer
) cur ON cur.customer_hk = s.hk AND cur.rn = 1
WHERE cur.hash_diff IS DISTINCT FROM s.hash_diff;

INSERT INTO sat_product
SELECT s.hk, m.load_dts, s.hash_diff, s.product_name, m.record_source
FROM (
    SELECT md5(CAST(product_id AS VARCHAR)) AS hk,
           md5(COALESCE(product_name, '')) AS hash_diff,
           product_name
    FROM stg_products
) s
CROSS JOIN load_meta m
LEFT JOIN (
    SELECT product_hk, hash_diff,
           ROW_NUMBER() OVER (PARTITION BY product_hk ORDER BY load_dts DESC) AS rn
    FROM sat_product
) cur ON cur.product_hk = s.hk AND cur.rn = 1
WHERE cur.hash_diff IS DISTINCT FROM s.hash_diff;

INSERT INTO sat_order
SELECT s.hk, m.load_dts, s.hash_diff, s.order_date, s.freight, m.record_source
FROM (
    SELECT md5(CAST(order_id AS VARCHAR)) AS hk,
           md5(COALESCE(CAST(order_date AS VARCHAR), '') || '||' || COALESCE(CAST(freight AS VARCHAR), '')) AS hash_diff,
           order_date, freight
    FROM stg_orders
) s
CROSS JOIN load_meta m
LEFT JOIN (
    SELECT order_hk, hash_diff,
           ROW_NUMBER() OVER (PARTITION BY order_hk ORDER BY load_dts DESC) AS rn
    FROM sat_order
) cur ON cur.order_hk = s.hk AND cur.rn = 1
WHERE cur.hash_diff IS DISTINCT FROM s.hash_diff;

INSERT INTO sat_order_line
SELECT s.hk, m.load_dts, s.hash_diff, s.amount, m.record_source
FROM (
    SELECT md5(CAST(order_id AS VARCHAR) || '||' || CAST(product_id AS VARCHAR) || '||' || CAST(line_id AS VARCHAR)) AS hk,
           md5(COALESCE(CAST(amount AS VARCHAR), '')) AS hash_diff,
           amount
    FROM stg_order_lines
) s
CROSS JOIN load_meta m
LEFT JOIN (
    SELECT order_line_hk, hash_diff,
           ROW_NUMBER() OVER (PARTITION BY order_line_hk ORDER BY load_dts DESC) AS rn
    FROM sat_order_line
) cur ON cur.order_line_hk = s.hk AND cur.rn = 1
WHERE cur.hash_diff IS DISTINCT FROM s.hash_diff;

-- Row counts after this run ---------------------------------------------------
SELECT (SELECT load_dts FROM load_meta)                 AS load_dts,
       (SELECT COUNT(*) FROM hub_customer)              AS hub_customer,
       (SELECT COUNT(*) FROM hub_order)                 AS hub_order,
       (SELECT COUNT(*) FROM hub_product)               AS hub_product,
       (SELECT COUNT(*) FROM link_customer_order)       AS link_cust_order,
       (SELECT COUNT(*) FROM link_order_line)           AS link_order_line,
       (SELECT COUNT(*) FROM sat_customer)              AS sat_customer,
       (SELECT COUNT(*) FROM sat_product)               AS sat_product,
       (SELECT COUNT(*) FROM sat_order)                 AS sat_order,
       (SELECT COUNT(*) FROM sat_order_line)            AS sat_order_line;
