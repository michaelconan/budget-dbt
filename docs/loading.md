# Loading Process

The data loading process involves moving raw transaction data from various banking sources into the DuckDB database.

## Sources

The system supports the following sources:
- **Revolut**: Personal, Spouse, and Joint account transaction exports.
- **Bank of America (BoA)**: Transaction activity exports.

## Pipeline Steps

1.  **Raw Data Placement**:
    - Raw CSV files should be placed in the `data/` directory:
        - `data/bofa/*.csv`
        - `data/revolut/personal/*.csv`
        - `data/revolut/spouse/*.csv`
        - `data/revolut/joint/*.csv`
2.  **Loading via dbt**:
    - Transaction CSV files are read directly by dbt using DuckDB's `external_location` configured in source YAML properties.
    - When running locally (`target: local`), dbt automatically uses mock data files located in `dbt/mocks/`.
