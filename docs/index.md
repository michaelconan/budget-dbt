# Budget DBT Wiki

Welcome to the Budget DBT project documentation. This system is designed to track and analyze personal finances by processing transaction data from multiple banking sources using dbt and DuckDB.

## Overview

The project automates the following:
1.  **Extraction**: Loading raw CSV data from Bank of America and Revolut.
2.  **Transformation**: Cleaning and standardizing transaction data using dbt.
3.  **Analysis**: Categorizing transactions and calculating metrics.
4.  **Visualization**: Displaying insights through a Streamlit dashboard.

## Key Components

- **DuckDB**: The core analytical database.
- **dbt (data build tool)**: Handles SQL-based transformations, testing, and documentation.
- **MkDocs**: Provides this searchable wiki for project documentation.
- **Streamlit**: Interactive dashboard for financial analysis.
