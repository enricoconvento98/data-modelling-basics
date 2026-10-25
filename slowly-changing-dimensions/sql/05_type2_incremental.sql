-- 05_type2_incremental.sql
-- Maintaining a Type 2 dimension incrementally (instead of rebuilding it).
--
-- A new batch arrives from the source, effective 2024-05-01:
--   * Beta Srl moved to Florence     -> must create a new version
--   * Acme Ltd still in Rome         -> no change, must NOT create a version
--   * Gamma SpA is a new customer    -> must create its first version
-- Then a new sale for Beta arrives on 2024-05-10.

DROP TABLE IF EXISTS change_batch;

CREATE TABLE change_batch AS
SELECT * FROM (VALUES
    (1, 'Acme Ltd',  'Rome',     DATE '2024-05-01'),
    (2, 'Beta Srl',  'Florence', DATE '2024-05-01'),
    (3, 'Gamma SpA', 'Naples',   DATE '2024-05-01')
) AS t(customer_id, customer_name, city, effective_date);

-- Step 1: expire the current version of every customer whose tracked
-- attributes changed. Close the interval at the new effective date.
UPDATE dim_customer_t2
SET valid_to   = b.effective_date,
    is_current = FALSE
FROM change_batch b
WHERE dim_customer_t2.customer_id = b.customer_id
  AND dim_customer_t2.is_current
  AND (dim_customer_t2.city          <> b.city
    OR dim_customer_t2.customer_name <> b.customer_name);

-- Step 2: insert a new current version for every batch row that has no
-- current version any more (changed customers) or never had one (new customers).
INSERT INTO dim_customer_t2 (customer_sk, customer_id, customer_name, city, valid_from, valid_to, is_current)
SELECT CAST((SELECT MAX(customer_sk) FROM dim_customer_t2)
            + ROW_NUMBER() OVER (ORDER BY b.customer_id) AS INTEGER),
       b.customer_id,
       b.customer_name,
       b.city,
       b.effective_date,
       DATE '9999-12-31',
       TRUE
FROM change_batch b
WHERE NOT EXISTS (
    SELECT 1 FROM dim_customer_t2 d
    WHERE d.customer_id = b.customer_id AND d.is_current
);

-- 5 versions: Acme still has 2, Beta now has 2, Gamma has 1.
SELECT * FROM dim_customer_t2 ORDER BY customer_id, valid_from;

-- New sale for Beta: the point-in-time lookup picks the Florence version.
INSERT INTO fact_sales
SELECT 4, d.customer_sk, DATE '2024-05-10', 30.00
FROM dim_customer_t2 d
WHERE d.customer_id = 2
  AND DATE '2024-05-10' >= d.valid_from
  AND DATE '2024-05-10' <  d.valid_to;

-- Old Beta sale stays in Turin, the new one goes to Florence:
-- Florence 30, Milan 100, Rome 50, Turin 70.
SELECT d.city, SUM(f.amount) AS amount
FROM fact_sales f
JOIN dim_customer_t2 d ON d.customer_sk = f.customer_sk
GROUP BY d.city
ORDER BY d.city;

-- Re-running the same batch is a no-op: nothing changed, and every customer
-- already has a current version, so neither step touches any row.
UPDATE dim_customer_t2
SET valid_to = b.effective_date, is_current = FALSE
FROM change_batch b
WHERE dim_customer_t2.customer_id = b.customer_id
  AND dim_customer_t2.is_current
  AND (dim_customer_t2.city <> b.city OR dim_customer_t2.customer_name <> b.customer_name);

INSERT INTO dim_customer_t2 (customer_sk, customer_id, customer_name, city, valid_from, valid_to, is_current)
SELECT CAST((SELECT MAX(customer_sk) FROM dim_customer_t2)
            + ROW_NUMBER() OVER (ORDER BY b.customer_id) AS INTEGER),
       b.customer_id, b.customer_name, b.city, b.effective_date, DATE '9999-12-31', TRUE
FROM change_batch b
WHERE NOT EXISTS (
    SELECT 1 FROM dim_customer_t2 d
    WHERE d.customer_id = b.customer_id AND d.is_current
);

SELECT COUNT(*) AS versions_after_rerun FROM dim_customer_t2;   -- still 5
