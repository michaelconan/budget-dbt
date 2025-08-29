# Budget DBT Project - DuckDB Edition
# Makefile for database operations and dbt workflows

# Database paths
DB_PATH = db/etl.duckdb
DATA_DIR = data
DOCS_DIR = docs
SEEDS_DIR = dbt/seeds
TMP_PROMPT = prompt.txt

# Python environment
PIPENV = pipenv run

# Default target
.DEFAULT_GOAL := help

## Help
.PHONY: help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

## Environment Setup
.PHONY: install
install: ## Install Python dependencies using pipenv
	pipenv install --dev

# Initialize database
.PHONY: init
init:
	@echo "Initializing DuckDB database..."
	@./script/init_db.sh $(DB_PATH)

# Load data
.PHONY: load
load:
	@echo "Loading data into DuckDB..."
	@./script/load.sh $(DB_PATH) $(DATA_DIR)

# Clean artifacts
.PHONY: clean
clean:
	@echo "Cleaning dbt artifacts..."
	$(PIPENV) dbt clean
	@echo "Cleaning database..."
	@rm -f $(DB_PATH)
	@rm -rf db/temp

# Install dbt packages
.PHONY: dbt-deps
dbt-deps:
	@echo "Installing dbt packages..."
	$(PIPENV) dbt deps

# Run dbt models
.PHONY: dbt-run
dbt-run:
	@echo "Running dbt models..."
	$(PIPENV) dbt run

# Run dbt seed
.PHONY: dbt-seed
dbt-seed:
	@echo "Running dbt seed..."
	$(PIPENV) dbt seed

# Run dbt tests
.PHONY: dbt-test
dbt-test:
	@echo "Running dbt tests..."
	$(PIPENV) dbt test

.PHONY: dbt-build
dbt-build: ## Run dbt build (seed, run, test)
	$(PIPENV) dbt build

.PHONY: export-data
export-data:
	@echo "Exporting transaction data..."
	@mkdir -p $(DATA_DIR)
	duckdb $(DB_PATH) "COPY transactions TO '$(DATA_DIR)/transactions.csv'"
	@echo "Transaction data exported to $(DATA_DIR)/transactions.csv"

.PHONY: categorise
categorise:
	@echo "Categorising vendors..."
	duckdb $(DB_PATH) "COPY category_audit TO '$(SEEDS_DIR)/vendor_categories.csv'"
	# Prepare prompt and provide to Gemini
	@echo "@dbt/seeds/vendor_categories.csv Replace all TBD categories" > $(TMP_PROMPT)
	@echo "with an appropriate category from the list of categories in" >> $(TMP_PROMPT)
	@echo "@dbt/dbt_project.yml and save the file to the same location." >> $(TMP_PROMPT)
	gemini -p $(TMP_PROMPT)
	@rm $(TMP_PROMPT)
	@echo "Categorised TBD vendors"

## Documentation (from docs.sh)
.PHONY: docs
docs: ## Generate static dbt documentation
	@echo "Generating static documentation..."
	$(PIPENV) dbt docs generate --static
	@mkdir -p $(DOCS_DIR)
	cp dbt/target/static_index.html $(DOCS_DIR)/index.html
	@echo "Static documentation generated at $(DOCS_DIR)/index.html"

## Code Quality (from fix-lint.sh)
.PHONY: fix-lint
fix-lint: ## Auto-fix and lint SQL files
	@echo "Auto-fixing SQL files..."
	$(PIPENV) sqlfluff fix dbt/
	@echo "Linting SQL files..."
	$(PIPENV) sqlfluff lint dbt/

# Data refresh
.PHONY: refresh
refresh: load dbt-deps dbt-seed dbt-run dbt-test
	@echo "Refresh completed!"

# Full setup
.PHONY: full-setup
full-setup: init load dbt-deps dbt-run
	@echo "Full setup completed!"

# Development workflow
.PHONY: dev
dev: dbt-run dbt-test
	@echo "Development workflow completed!"

## Utilities
.PHONY: db-shell
db-shell: ## Open SQLite shell for the database
	duckdb $(DB_PATH)
