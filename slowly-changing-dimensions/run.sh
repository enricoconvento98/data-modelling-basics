#!/usr/bin/env bash
# Run the Slowly Changing Dimensions examples with the DuckDB CLI.
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
    for f in sql/01_source.sql sql/02_type1.sql sql/03_type2.sql sql/04_type3_type6.sql sql/05_type2_incremental.sql; do
        echo ".print"
        echo ".print ===== $f ====="
        echo ".read $f"
    done
} | duckdb -bail "$DB"
