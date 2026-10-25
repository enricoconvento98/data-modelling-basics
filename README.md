# data-modelling-basics

[![CI](https://github.com/enricoconvento98/data-modelling-basics/actions/workflows/ci.yml/badge.svg)](https://github.com/enricoconvento98/data-modelling-basics/actions/workflows/ci.yml)

A learning repository for data modelling patterns. Each topic has its own
folder with an explanation (`README.md`) and small, runnable SQL examples
that work on [DuckDB](https://duckdb.org/) and PostgreSQL.

## Topics

| # | Topic | What it covers |
|---|-------|----------------|
| 1 | [Unified Star Schema](unified-star-schema/README.md) | Fan and chasm traps, the Puppini Bridge, querying every table through a single `_bridge` (Puppini & Inmon) |
| 2 | [Kimball Star Schema](kimball-star-schema/README.md) | Facts, dimensions and grain; allocation; drill-across with conformed dimensions; comparison with USS |
| 3 | [Slowly Changing Dimensions](slowly-changing-dimensions/README.md) | SCD types 0, 1, 2, 3 and 6; point-in-time fact lookup; incremental Type 2 merge |
| 4 | [Data Vault 2.0](data-vault/README.md) | Hubs, links and satellites; hash keys and hash diffs; idempotent insert-only loads; information marts |

Topics 1 and 2 use the same source data, so the two approaches can be compared
side by side. Topic 4 shows how the raw history of topic 3 comes for free in a
Data Vault.

## Running the examples

Each topic folder contains a `sql/` directory with numbered scripts and a
`run.sh` that executes them in order:

```sh
cd unified-star-schema
./run.sh              # DuckDB CLI, in-memory
./run.sh --postgres   # PostgreSQL via psql (uses PGHOST, PGUSER, ...)
```

## dbt project

[`dbt-project/`](dbt-project/README.md) rebuilds all four topics as a dbt
project on DuckDB: staging / intermediate / marts layers, incremental Data Vault
loads, a snapshot for SCD Type 2, and 120+ tests (unit, generic, custom and
business-rule tests) proving the totals are right.

```sh
cd dbt-project
pip install -r requirements.txt
./run_dbt.sh
```

## Tech stack

SQL (DuckDB, PostgreSQL) · dbt Core + dbt-duckdb · GitHub Actions · Mermaid

## CI

Every push runs all SQL examples on DuckDB and PostgreSQL, and the full dbt
build with tests ([workflow](.github/workflows/ci.yml)).
