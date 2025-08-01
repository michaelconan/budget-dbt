# Budget dbt Project

This dbt project transforms financial transaction data from multiple sources (Revolut and Bank of America) into a unified, standardized format for analysis.

## Project Structure

### Sources

Defined in `models/sources.yml`, these represent the raw data tables:

- **revolut**: Personal, spouse, and joint account transaction data from Revolut
  - `raw_revolut__personal`
  - `raw_revolut__spouse` 
  - `raw_revolut__joint`
- **bofa**: Bank of America activity data
  - `raw_bofa__activity`

### Staging Layer (`models/staging/`)

The staging layer cleans and standardizes raw data from each source:

#### `stg_revolut__transactions.sql`
- **Purpose**: Combines personal, spouse, and joint Revolut accounts into unified format
- **Key Transformations**:
  - Unions all three Revolut account types
  - Generates surrogate keys using transaction details
  - Identifies transfers between accounts using `get_transfer_transactions` macro
  - Categorizes transactions using vendor mapping and keyword-based logic
  - Filters to completed transactions only
- **Output**: Standardized Revolut transaction data with transfer flags and categories

#### `stg_bofa__transactions.sql`
- **Purpose**: Cleans and standardizes Bank of America transaction data
- **Key Transformations**:
  - Parses account names into bank, type, and account components
  - Converts US date format (MM/DD/YYYY) to ISO format (YYYY-MM-DD)
  - Generates surrogate keys for unique identification
  - Identifies transfers between accounts
  - Standardizes description fields
- **Output**: Cleaned Bank of America transaction data with transfer flags

### Marts Layer (`models/marts/`)

The marts layer contains business-ready models for analysis:

#### `transactions.sql`
- **Purpose**: Creates unified transaction dataset combining all sources
- **Key Features**:
  - Unions Revolut and Bank of America data with consistent schema
  - Applies currency conversion using foreign exchange rates
  - Maps source-specific categories to standardized category types
  - Provides both original currency amounts and USD-converted amounts
- **Output Columns**:
  - `transaction_key`: Unique identifier
  - `country`, `source`, `bank`: Source identification
  - `account_type`, `account`: Account details
  - `date`, `description`: Transaction basics
  - `category`, `category_type`: Categorization
  - `amount`, `currency`: Original transaction values
  - `fx_rate`, `amount_usd`: Currency conversion
  - `is_transfer`: Transfer flag for filtering

#### `fx_rates.sql`
- **Purpose**: Provides complete daily EUR/USD exchange rates
- **Key Features**:
  - Generates date spine from 2023-01-01 to current date
  - Fills missing exchange rate dates using forward-fill logic
  - Sources data from `google_finance__eur_usd` seed
- **Output**: Daily EUR/USD exchange rates with no gaps

### Seeds (`seeds/`)

Static reference data loaded into the warehouse:

#### `google_finance__eur_usd.csv`
- Historical EUR to USD exchange rates from Google Finance
- Used for currency conversion in the marts layer

#### `vendor_categories.csv`
- Mapping of vendor names/patterns to transaction categories
- Used in staging to categorize transactions based on description

#### `category_mapping.csv`
- Maps source-specific categories to standardized category types
- Enables consistent categorization across different banks

### Macros (`macros/`)

Reusable SQL functions:

#### `get_transfer_transactions`
- Identifies transactions that represent transfers between accounts
- Matches transactions with same date, opposite amounts across accounts

#### `categorise_keywords`
- Categorizes transactions based on keyword matching
- Uses category keywords defined in `dbt_project.yml` variables

#### `lite_date_spine`
- Generates a series of dates between start and end dates
- Used for filling gaps in exchange rate data

### Tests

Data quality assurance:

#### Unit Tests (`models/staging/unit_tests.yml`)
- Tests transfer identification logic with known scenarios
- Validates staging model transformations

#### Generic Tests
- Defined in model properties files
- Include uniqueness, not-null, and accepted values tests
- Custom regex validation for date formats

## Usage

### Quick Commands
```bash
# Install dependencies
dbt deps

# Run all models
dbt run

# Run tests
dbt test

# Build everything (seed + run + test)
dbt build
```

### Development Workflow
```bash
# Run specific model
dbt run --select stg_revolut__transactions

# Run model and downstream dependencies
dbt run --select stg_revolut__transactions+

# Test specific model
dbt test --select transactions
```
