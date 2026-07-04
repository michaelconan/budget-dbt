# dbt Transforms

The dbt project transforms raw ingested data into clean, analyzed marts.

## Project Structure

- **Staging (`models/staging/`)**: Minimal cleanup and standardization (renaming columns, casting types).
- **Intermediate (`models/intermediate/`)**: Business logic that isn't quite a final mart, like the `category_audit` model.
- **Marts (`models/marts/`)**: Final, consumer-ready tables like `transactions`.

## Key Models

- `stg_revolut__transactions`: Cleans Revolut-specific exports.
- `stg_bofa__transactions`: Cleans Bank of America exports.
- `transactions`: The primary table for analysis, combining all sources and applying FX rates where necessary.

## Custom Macros

- `categorise_keywords`: Uses keywords defined in `dbt_project.yml` to automatically assign categories to transactions.
- `standardise_ascii`: Cleans up special characters from vendor names.
