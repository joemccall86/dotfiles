# DuckDB for Large CSV / Data Files

When a task involves a large CSV (or other tabular data file: TSV, Parquet, JSON), do not `cat`, `Read`, `grep`, or otherwise load the raw file into context. Use the `duckdb` CLI to query it instead, and only bring the query *results* into context.

DuckDB can query CSV files directly without importing them first.

## Answering questions about data

Use `duckdb -c "<SQL>"` against the file path directly:

```bash
duckdb -c "SELECT COUNT(*) FROM read_csv_auto('/path/to/file.csv');"
duckdb -c "SELECT * FROM read_csv_auto('/path/to/file.csv') LIMIT 20;"
duckdb -c "DESCRIBE SELECT * FROM read_csv_auto('/path/to/file.csv');"
duckdb -c "SELECT col_a, COUNT(*) FROM read_csv_auto('/path/to/file.csv') GROUP BY col_a ORDER BY 2 DESC LIMIT 10;"
```

For multi-statement or complex analysis, write the SQL to a scratch `.sql` file in the scratchpad directory and run `duckdb < scratch.sql`, rather than inlining a long `-c` string.

## Rules

- Never read a large CSV/data file directly with the `Read` tool or `cat`/`head`/`tail` just to "see what's in it" — run `DESCRIBE` or `LIMIT` queries in duckdb instead.
- Always inspect schema first (`DESCRIBE` or `SELECT * ... LIMIT 5`) before writing aggregate queries, since column names/types are unknown up front.
- Prefer `read_csv_auto()` for schema inference; fall back to explicit `read_csv(..., columns = {...})` only if type inference is wrong.
- For repeated queries against the same file, load it into an in-memory or on-disk DuckDB table once (`CREATE TABLE t AS SELECT * FROM read_csv_auto(...)`) rather than re-scanning the CSV every time.
- Treat "large" as anything you wouldn't want to paste into a chat — if in doubt, check size first with `ls -la` or `wc -l`, not by opening it.
