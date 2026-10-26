#!/usr/bin/env bash
# Builds and tests the whole project from scratch, simulating three daily runs:
#
#   run 1  Data Vault loads extract 1          snapshot taken on 2024-02-01
#   run 2  Data Vault loads extract 1 AGAIN    snapshot taken on 2024-04-01
#          (must insert nothing: idempotent)   (Acme has moved to Rome)
#   run 3  Data Vault loads extract 2          snapshot taken on 2024-06-01
#          (Acme moved, new order 101)         (Beta moved, Gamma is new)
#
# `dbt build` runs seeds, models, snapshots, unit tests and data tests in
# dependency order and stops downstream nodes when a test fails.
set -euo pipefail

cd "$(dirname "$0")"
export DBT_PROFILES_DIR="${DBT_PROFILES_DIR:-$PWD}"
export DBT_DUCKDB_PATH="${DBT_DUCKDB_PATH:-data_modelling_basics.duckdb}"

rm -f "$DBT_DUCKDB_PATH" "$DBT_DUCKDB_PATH.wal"

echo "=== run 1: extract 1, snapshot as of 2024-02-01"
dbt build --vars '{extract_no: 1, scd_as_of: "2024-02-01"}'

echo "=== run 2: extract 1 again, snapshot as of 2024-04-01"
dbt build --vars '{extract_no: 1, scd_as_of: "2024-04-01"}'

echo "=== run 3: extract 2, snapshot as of 2024-06-01"
dbt build --vars '{extract_no: 2, scd_as_of: "2024-06-01"}'

echo "=== results"
for model in uss_customer_totals kimball_customer_totals uss_products_never_sold \
             scd_dim_customer_type2 scd_sales_by_city \
             dv_customer_totals dv_customer_history; do
    dbt show --select "$model" --limit 20 --vars '{extract_no: 2, scd_as_of: "2024-06-01"}' --quiet
done

# A snapshot's history lives in its table, so query it directly.
dbt show --quiet --inline "
    select customer_id, customer_name, city, dbt_valid_from, dbt_valid_to
    from {{ ref('snp_scd_customer') }}
    order by customer_id, dbt_valid_from"

echo "=== the traps (analyses)"
dbt show --select fan_trap --quiet
dbt show --select chasm_trap --quiet
