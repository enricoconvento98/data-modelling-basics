#!/usr/bin/env bash
# Run the Data Vault example with the DuckDB CLI.
# Usage: ./run.sh [database-file]   (default: in-memory database)
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v duckdb >/dev/null 2>&1; then
    echo "duckdb CLI not found: install it from https://duckdb.org/docs/installation/" >&2
    exit 1
fi

DB="${1:-:memory:}"

{
    echo ".mode table"
    for f in sql/01_staging_load1.sql sql/02_raw_vault.sql sql/03_load_raw_vault.sql sql/03_load_raw_vault.sql sql/04_staging_load2.sql sql/03_load_raw_vault.sql sql/05_information_mart.sql; do
        echo ".print"
        echo ".print ===== $f ====="
        echo ".read $f"
    done
} | duckdb -bail "$DB"
