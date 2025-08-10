# Gemini Project Context

This document provides context for the `budget-dbt` project to ensure that any contributions align with its established conventions and practices.

## Project Overview

The `budget-dbt` project is designed to standardize and analyze financial transactions from different banking systems. It uses dbt (data build tool) to perform key data transformations, including creating unique transaction identifiers, flagging inter-account transfers, and converting currencies to a standard unit for analysis. The processed data is stored in a SQLite database.

- **Raw Data**: Stored in the `data/` directory, organized by source.
- **Database Schema**: Defined in `.sql` files within the `ddl/` directory.
- **dbt Models**: Located in `dbt/models/`, containing the SQL for data transformation.
- **Scripts**: Automation scripts for tasks like data loading are in the `script/` directory.

## Tech Stack

- **Database**: DuckDB
- **Data Transformation**: dbt
- **Language**: SQL, with Python for scripting and environment management.
- **Dependency Management**: Pipenv
- **Automation**: `Makefile` for running common tasks.
- **CI/CD**: GitHub Actions for documentation generation.
- **Code Formatting**: `sqlfluff` for SQL linting and formatting.

## Development Workflow

The project uses a `Makefile` to streamline common development tasks.

- **To set up the development environment**:
  ```bash
  make install
  ```
- **To set up the database (create tables and load data)**:
  ```bash
t  make init
  ```
- **To run dbt models and tests**:
  ```bash
  make dev
  ```
- **To run a full data refresh**:
  ```bash
  make full-setup
  ```
- **To lint and format SQL code**:
  ```bash
  make fix-lint
  ```

## SQL Style Guide

The project enforces a specific SQL style using `sqlfluff`. Key conventions are defined in the `.sqlfluff` file:

- **Dialect**: `duckdb`
- **Templater**: `dbt`
- **Max Line Length**: 80 characters
- **Indentation**: 4 spaces
- **Capitalization**: All keywords (e.g., `select`, `from`) and identifiers must be in `lower` case.
- **Aliasing**: Tables and columns must use explicit aliasing (e.g., `table as t`).

Please adhere to these conventions when writing or modifying SQL code.
