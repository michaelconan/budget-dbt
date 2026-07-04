# Loading Process

The data loading process involves moving raw transaction data from various banking sources into the DuckDB database.

## Sources

The system supports the following sources:
- **Revolut**: Personal, Spouse, and Joint account transaction exports.
- **Bank of America (BoA)**: Transaction activity exports.

## Pipeline Steps

1.  **Initialization**:
    - The database is initialized using `make init`, which runs `script/init_db.sh`.
2.  **Raw Data Placement**:
    - Raw CSV files should be placed in the `data/` directory:
        - `data/bofa/*.csv`
        - `data/revolut/personal/*.csv`
        - `data/revolut/spouse/*.csv`
        - `data/revolut/joint/*.csv`
3.  **Loading**:
    - Run `make load` to execute `script/load.sh`.
    - This script uses DuckDB's native CSV reading capabilities to ingest the data into staging tables.
