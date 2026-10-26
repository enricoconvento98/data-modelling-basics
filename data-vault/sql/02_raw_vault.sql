-- 02_raw_vault.sql
-- Raw Data Vault 2.0 structures.
--   Hubs       : one row per unique business key            (hub_*)
--   Links      : one row per unique relationship of hubs    (link_*)
--   Satellites : descriptive attributes + their history      (sat_*)
-- *_hk are hash keys: MD5 of the normalised business key(s).
-- Every row carries load_dts and record_source. Tables are insert-only.

CREATE TABLE hub_customer (
    customer_hk   CHAR(32)    PRIMARY KEY,
    customer_id   INTEGER     NOT NULL,     -- business key
    load_dts      TIMESTAMP   NOT NULL,
    record_source VARCHAR(50) NOT NULL
);

CREATE TABLE hub_order (
    order_hk      CHAR(32)    PRIMARY KEY,
    order_id      INTEGER     NOT NULL,
    load_dts      TIMESTAMP   NOT NULL,
    record_source VARCHAR(50) NOT NULL
);

CREATE TABLE hub_product (
    product_hk    CHAR(32)    PRIMARY KEY,
    product_id    INTEGER     NOT NULL,
    load_dts      TIMESTAMP   NOT NULL,
    record_source VARCHAR(50) NOT NULL
);

-- customer places order
CREATE TABLE link_customer_order (
    customer_order_hk CHAR(32)    PRIMARY KEY,
    customer_hk       CHAR(32)    NOT NULL REFERENCES hub_customer (customer_hk),
    order_hk          CHAR(32)    NOT NULL REFERENCES hub_order (order_hk),
    load_dts          TIMESTAMP   NOT NULL,
    record_source     VARCHAR(50) NOT NULL
);

-- order contains product; line_id is a dependent child key
-- (the same product can appear on several lines of one order)
CREATE TABLE link_order_line (
    order_line_hk CHAR(32)    PRIMARY KEY,
    order_hk      CHAR(32)    NOT NULL REFERENCES hub_order (order_hk),
    product_hk    CHAR(32)    NOT NULL REFERENCES hub_product (product_hk),
    line_id       INTEGER     NOT NULL,
    load_dts      TIMESTAMP   NOT NULL,
    record_source VARCHAR(50) NOT NULL
);

CREATE TABLE sat_customer (
    customer_hk   CHAR(32)    NOT NULL REFERENCES hub_customer (customer_hk),
    load_dts      TIMESTAMP   NOT NULL,
    hash_diff     CHAR(32)    NOT NULL,     -- MD5 of all attributes: change detection
    customer_name VARCHAR(50),
    city          VARCHAR(50),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (customer_hk, load_dts)
);

CREATE TABLE sat_product (
    product_hk    CHAR(32)    NOT NULL REFERENCES hub_product (product_hk),
    load_dts      TIMESTAMP   NOT NULL,
    hash_diff     CHAR(32)    NOT NULL,
    product_name  VARCHAR(50),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (product_hk, load_dts)
);

CREATE TABLE sat_order (
    order_hk      CHAR(32)    NOT NULL REFERENCES hub_order (order_hk),
    load_dts      TIMESTAMP   NOT NULL,
    hash_diff     CHAR(32)    NOT NULL,
    order_date    DATE,
    freight       DECIMAL(10, 2),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (order_hk, load_dts)
);

CREATE TABLE sat_order_line (
    order_line_hk CHAR(32)    NOT NULL REFERENCES link_order_line (order_line_hk),
    load_dts      TIMESTAMP   NOT NULL,
    hash_diff     CHAR(32)    NOT NULL,
    amount        DECIMAL(10, 2),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (order_line_hk, load_dts)
);
