#!/usr/bin/env bash
# Run the Unified Star Schema example.
# Usage: ./run.sh [database-file]   DuckDB CLI (default: in-memory database)
#        ./run.sh --postgres        psql, using the usual PG* environment variables
set -euo pipefail

cd "$(dirname "$0")"

FILES=(
    sql/01_source_tables.sql
    sql/02_naive_joins.sql
    sql/03_bridge.sql
    sql/04_uss_queries.sql
)

if [[ "${1:-}" == "--postgres" ]]; then
    for f in "${FILES[@]}"; do
        echo
        echo "===== $f ====="
        PGOPTIONS="${PGOPTIONS:-} -c client_min_messages=warning" psql -X -q -v ON_ERROR_STOP=1 -f "$f"
    done
    exit 0
fi

if ! command -v duckdb >/dev/null 2>&1; then
    echo "duckdb CLI not found: install it from https://duckdb.org/docs/installation/" >&2
    exit 1
fi

DB="${1:-:memory:}"

{
    echo ".mode table"
    for f in "${FILES[@]}"; do
        echo ".print"
        echo ".print ===== $f ====="
        echo ".read $f"
    done
} | duckdb -bail "$DB"
