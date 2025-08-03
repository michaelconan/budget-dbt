# budget-dbt

A comprehensive budget tracking and analysis system using dbt and DuckDB to process transaction data from multiple banking sources.

## 🚀 Migration to DuckDB

This project has been migrated from SQLite to DuckDB for improved performance, better SQL compatibility, and enhanced analytical capabilities.

### Key Improvements

- **Performance**: DuckDB provides significantly better query performance for analytical workloads
- **SQL Compatibility**: Full SQL standard support with modern SQL features
- **Parallel Processing**: Multi-threaded execution for faster data processing
- **Memory Management**: Efficient memory usage with configurable limits
- **Native Functions**: Built-in support for date functions, window functions, and more

## 📋 Prerequisites

- **DuckDB**: Install DuckDB CLI and Python bindings
  ```bash
  # Install DuckDB CLI
  winget install duckdb.cli
  ```

- **dbt**: Install dbt with DuckDB adapter
  ```bash
  make install
  ```

- **Python**: Python 3.8+ with pip

## 🏗️ Project Structure

```
budget-dbt/
├── data/                   # Raw CSV transaction data
│   ├── bofa/               # Bank of America exports
│   └── revolut/            # Revolut exports
│       ├── joint/
│       ├── personal/
│       └── spouse/
├── db/                     # DuckDB database files
├── dbt/                    # dbt project
│   ├── models/             # Data models
│   │   ├── staging/        # Staging models
│   │   ├── intermediate/   # Intermediate models
│   │   └── marts/          # Mart models
│   ├── macros/             # Custom macros
│   ├── seeds/              # Static data files
│   └── tests/              # Custom data tests
├── ddl/                    # Database schema definitions
├── script/                 # Utility scripts
└── docs/                   # Generated documentation
```

## 🚀 Quick Start

1. **Initialize the database**:
   ```bash
   make init
   ```

2. **Load transaction data**:
   ```bash
   make load
   ```

3. **Install dbt dependencies**:
   ```bash
   make dbt-deps
   ```

4. **Run the data pipeline**:
   ```bash
   make dbt-run
   ```

5. **Run tests**:
   ```bash
   make dbt-test
   ```

## 📊 Data Sources

### Revolut
- **Personal Account**: Individual transaction data
- **Spouse Account**: Partner's transaction data  
- **Joint Account**: Shared account transactions

### Bank of America
- **Activity Data**: Transaction exports from "My Financial Picture"

## 🔧 Configuration

### Database Settings
- **Database**: `db/etl.duckdb`
- **Memory Limit**: 2GB (configurable in `profiles.yml`)
- **Threads**: 4 (configurable in `profiles.yml`)

### dbt Configuration
- **Profile**: `budget_dbt`
- **Target**: `dev`
- **Materialization**: Views for staging, tables for marts

## 📈 Data Models

### Staging Layer
- `fx_rates`: Historical EUR/USD exchange rates
- `stg_revolut__transactions`: Cleaned Revolut transaction data
- `stg_bofa__transactions`: Cleaned Bank of America transaction data

### Intermediate Layer
- `category_audit`: Categorised and new vendors to further categorise

### Mart Layer
- `transactions`: Combined transaction data with FX conversion

## 🧪 Testing

The project includes comprehensive data tests:

- **Column tests**: Not null, unique, accepted values
- **Custom tests**: Regex pattern matching, business logic validation
- **Generic tests**: Cross-column validation

Run tests with:
```bash
make dbt-test
```

## 📚 Documentation

Generate documentation:
```bash
make docs
```

## 🔄 Workflows

### Development
```bash
make dev  # Run models and tests
```

### Full Setup
```bash
make full-setup  # Complete pipeline setup
```

### Clean Slate
```bash
make clean  # Remove all artifacts
```

## 🛠️ Custom Macros

### `categorise_keywords`
Keyword-based transaction categorization using configurable category mappings.

### `get_transfer_transactions`
Identifies transfer transactions between accounts.

## 🔍 Data Quality

### Validation Rules
- Transaction amounts must be numeric
- Dates must be in valid format
- Required fields must not be null
- Category values must be from accepted list

### Monitoring
- Automated data quality checks
- Business rule validation
- Cross-source consistency checks
