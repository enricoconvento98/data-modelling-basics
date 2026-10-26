-- 05_information_mart.sql
-- The raw vault is not meant for end users. Information marts (often views)
-- reshape it into dimensions and facts. Expected after both loads:
--   freight 15 (10 + 5), amount 140 (100 + 40).

DROP VIEW IF EXISTS mart_fact_order_line;
DROP VIEW IF EXISTS mart_fact_order;
DROP VIEW IF EXISTS mart_dim_product;
DROP VIEW IF EXISTS mart_dim_customer;

-- Current-state dimensions: latest satellite row per hub key.
CREATE VIEW mart_dim_customer AS
SELECT h.customer_hk, h.customer_id, s.customer_name, s.city
FROM hub_customer h
JOIN (
    SELECT sc.*, ROW_NUMBER() OVER (PARTITION BY customer_hk ORDER BY load_dts DESC) AS rn
    FROM sat_customer sc
) s ON s.customer_hk = h.customer_hk AND s.rn = 1;

CREATE VIEW mart_dim_product AS
SELECT h.product_hk, h.product_id, s.product_name
FROM hub_product h
JOIN (
    SELECT sp.*, ROW_NUMBER() OVER (PARTITION BY product_hk ORDER BY load_dts DESC) AS rn
    FROM sat_product sp
) s ON s.product_hk = h.product_hk AND s.rn = 1;

-- Facts, one per grain (order and order line), as in the Kimball topic.
-- (mart_ prefix keeps the names distinct from the Kimball tables.)
CREATE VIEW mart_fact_order AS
SELECT lco.customer_hk, h.order_id, s.order_date, s.freight
FROM hub_order h
JOIN link_customer_order lco ON lco.order_hk = h.order_hk
JOIN (
    SELECT so.*, ROW_NUMBER() OVER (PARTITION BY order_hk ORDER BY load_dts DESC) AS rn
    FROM sat_order so
) s ON s.order_hk = h.order_hk AND s.rn = 1;

CREATE VIEW mart_fact_order_line AS
SELECT lco.customer_hk, l.product_hk, ho.order_id, l.line_id, s.amount
FROM link_order_line l
JOIN hub_order ho            ON ho.order_hk  = l.order_hk
JOIN link_customer_order lco ON lco.order_hk = l.order_hk
JOIN (
    SELECT sol.*, ROW_NUMBER() OVER (PARTITION BY order_line_hk ORDER BY load_dts DESC) AS rn
    FROM sat_order_line sol
) s ON s.order_line_hk = l.order_line_hk AND s.rn = 1;

-- Totals by customer (drill-across: aggregate each grain, then join).
WITH ords AS (
    SELECT customer_hk, SUM(freight) AS freight FROM mart_fact_order GROUP BY customer_hk
), lines AS (
    SELECT customer_hk, SUM(amount) AS amount FROM mart_fact_order_line GROUP BY customer_hk
)
SELECT c.customer_name, c.city, o.freight, l.amount
FROM mart_dim_customer c
LEFT JOIN ords  o ON o.customer_hk = c.customer_hk
LEFT JOIN lines l ON l.customer_hk = c.customer_hk;

-- Amount by product: Gadget 30, Gizmo 40, Widget 70.
SELECT p.product_name, SUM(f.amount) AS amount
FROM mart_fact_order_line f
JOIN mart_dim_product p ON p.product_hk = f.product_hk
GROUP BY p.product_name
ORDER BY p.product_name;

-- History comes for free: the satellite is effectively an SCD Type 2.
-- valid_to is derived with LEAD, never stored (the vault stays insert-only).
SELECT h.customer_id,
       s.city,
       s.load_dts AS valid_from,
       LEAD(s.load_dts) OVER (PARTITION BY s.customer_hk ORDER BY s.load_dts) AS valid_to,
       s.record_source
FROM sat_customer s
JOIN hub_customer h ON h.customer_hk = s.customer_hk
ORDER BY h.customer_id, s.load_dts;

-- Auditability: when did each order first appear, and from which source?
SELECT order_id, load_dts, record_source
FROM hub_order
ORDER BY order_id;
