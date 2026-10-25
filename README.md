# data-modelling-basics

A learning repository for data modelling patterns. Each topic has its own
folder with an explanation (`README.md`) and small, runnable SQL examples
that work on [DuckDB](https://duckdb.org/) and PostgreSQL.

## Topics

| # | Topic | What it covers |
|---|-------|----------------|
| 1 | [Unified Star Schema](unified-star-schema/README.md) | Fan and chasm traps, the Puppini Bridge, querying every table through a single `_bridge` (Puppini & Inmon) |

## Running the examples

Each topic folder contains a `sql/` directory with numbered scripts and a
`run.sh` that executes them in order with the `duckdb` CLI:

```sh
cd unified-star-schema
./run.sh
```

The same scripts can be run against PostgreSQL with `psql -f`, in order.
