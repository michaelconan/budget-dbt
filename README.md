# budget-dbt

Project using data build tool (dbt) to load, normalize, and analyze financial transactions with SQLite.

## Purpose

The project is designed to standardize transactional data across different bank systems.

The following key transformations are performed:
- **Unique Keys**: Create hashed surrogate keys for predictable unique transaction identifiers.
- **Transfer Flags**: Identify transactions representing transfers between accounts to exclude them from analysis.
- **Currency Conversion**: Apply Google Finance foreign exchange rates for standard monetary unit of analysis.

## Project Structure

- **data**: Contains raw data files organized by source (e.g., bofa, revolut).
- **db**: SQLite database files.
- **dbt**:
  - `models`: Contains SQL models for data transformations.
  - `macros`: Common SQL functions used across models.
  - `seeds`: CSV files for basic data inputs.
  - `tests`: Generic and custom tests for data validation.
- **ddl**: SQL schema files for raw data tables.
- **script**: Scripts for data loading and other automation tasks.
- **docs**: Directory for generated documentation.
  
## Setup

### Prerequisites

- SQLite CLI, which can be installed using:

  ```sh
  winget install --id SQLite.SQLite
  ```

- SQLite extensions for cryptography and regular expressions:

  1. Install the [SQLPkg CLI](https://github.com/nalgeon/sqlpkg-cli).
  2. Install the crypto and regexp extensions:

     ```sh
     sqlpkg install nalgeon/crypto nalgeon/regexp
     ```

  3. Add extension paths to the dbt `profiles.yml` file:

     ```yaml
     dev:
       extensions:
         - '~/.sqlpkg/nalgeon/crypto/crypto.dll'
         - '~/.sqlpkg/nalgeon/regexp/regexp.dll'
     ```

  4. Add the extensions to the `~/.sqliterc` file:

     ```sh
     .headers on
     .load C:\Users\{USER}\.sqlpkg\nalgeon\crypto\crypto.dll
     .load C:\Users\{USER}\.sqlpkg\nalgeon\regexp\regexp.dll
     ```

### Installation

1. Clone the repository and navigate to the project directory.
2. Install Python dependencies using Pipenv:

   ```sh
   pipenv install --dev
   ```

3. Create tables and load data:

   ```sh
   make setup-db
   ```

4. Run dbt models:

   ```sh
   make dbt-run
   ```

## Approach

- **Data Loading**: Raw data is loaded into SQLite tables using `script/load.sh`.
- **Data Transformation**: dbt models in `dbt/models` transform loaded data into meaningful insights.
- **Testing**: dbt tests are used for validating data consistency.
- **Documentation**: Automated using GitHub Actions with results stored in the `docs` directory.

## Usage

- **Quick Development Cycle**:

  ```sh
  make dev
  ```

- **Full Data Refresh**:

  ```sh
  make refresh
  ```

- **Generating Documentation**:
  
  Documentation is auto-generated and deployed using GitHub Actions.

---

To maintain consistency, check out the available Makefile targets for automation tasks, like `install`, `dbt-build`, `dbt-clean`, etc.
