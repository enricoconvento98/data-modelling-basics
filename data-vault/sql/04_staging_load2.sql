-- 04_staging_load2.sql
-- Second full extract, one month later. Compared with load 1:
--   * Acme Ltd moved from Milan to Rome          -> new sat_customer row only
--   * new order 101 (freight 5), one line of
--     Gizmo for 40                                -> new hub, link and sat rows
--   * everything else is unchanged                -> nothing inserted
-- Replace staging contents and the load metadata, then re-run 03.

DELETE FROM load_meta;
INSERT INTO load_meta VALUES (TIMESTAMP '2024-02-29 00:00:00', 'shop_db');

DELETE FROM stg_order_lines;
DELETE FROM stg_orders;
DELETE FROM stg_products;
DELETE FROM stg_customers;

INSERT INTO stg_customers VALUES (1, 'Acme Ltd', 'Rome');
INSERT INTO stg_products  VALUES (1, 'Widget'), (2, 'Gadget'), (3, 'Gizmo');
INSERT INTO stg_orders VALUES
    (100, 1, DATE '2024-01-15', 10.00),
    (101, 1, DATE '2024-02-10',  5.00);
INSERT INTO stg_order_lines VALUES
    (1001, 100, 1, 20.00),
    (1002, 100, 2, 30.00),
    (1003, 100, 1, 50.00),
    (1004, 101, 3, 40.00);
