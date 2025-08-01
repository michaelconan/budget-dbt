# Budget DBT Project Makefile
# Automates common tasks for the budget data pipeline

# Variables
DB_PATH = db/etl.db
DATA_DIR = data
DOCS_DIR = docs
DDL_DIR = ddl
TEMP_SQL = temp.sql

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

## Database Setup
.PHONY: ddl
ddl: ## Create SQLite raw tables from schema files
	@echo "Creating database schema..."
	@for file in $(DDL_DIR)/*.sql; do \
		echo "Executing $$file"; \
		sqlite3 $(DB_PATH) ".read $$file"; \
	done

.PHONY: load
load:
	@bash script/load.sh $(DB_PATH) $(DATA_DIR)

## DBT Operations
.PHONY: dbt-run
dbt-run: ## Run dbt models
	$(PIPENV) dbt run

.PHONY: dbt-test
dbt-test: ## Run dbt tests
	$(PIPENV) dbt test

.PHONY: dbt-build
dbt-build: ## Run dbt build (seed, run, test)
	$(PIPENV) dbt build

.PHONY: dbt-clean
dbt-clean: ## Clean dbt artifacts
	$(PIPENV) dbt clean

## Documentation (from docs.sh)
.PHONY: docs
docs: ## Generate static dbt documentation
	@echo "Generating static documentation..."
	$(PIPENV) dbt docs generate --static
	@mkdir -p $(DOCS_DIR)
	cp dbt/target/static_index.html $(DOCS_DIR)/index.html
	@echo "Static documentation generated at $(DOCS_DIR)/index.html"

## Data Export (from export.sh)
.PHONY: export
export: ## Export transactions data to CSV
	@echo "Exporting transaction data..."
	@mkdir -p $(DATA_DIR)
	@echo ".mode csv" > $(TEMP_SQL)
	@echo ".headers on" >> $(TEMP_SQL)
	@echo ".output $(DATA_DIR)/transactions.csv" >> $(TEMP_SQL)
	@echo "SELECT * FROM transactions;" >> $(TEMP_SQL)
	@echo ".quit" >> $(TEMP_SQL)
	sqlite3 $(DB_PATH) ".read $(TEMP_SQL)"
	@rm $(TEMP_SQL)
	@echo "Transaction data exported to $(DATA_DIR)/transactions.csv"

## Code Quality (from fix-lint.sh)
.PHONY: fix-lint
fix-lint: ## Auto-fix and lint SQL files
	@echo "Auto-fixing SQL files..."
	$(PIPENV) sqlfluff fix dbt/
	@echo "Linting SQL files..."
	$(PIPENV) sqlfluff lint dbt/

## Common Workflows
.PHONY: setup-db
setup-db: ddl load ## Create tables and load data (full database setup)

.PHONY: refresh
refresh: setup-db dbt-build export ## Full data refresh pipeline

.PHONY: dev
dev: dbt-run dbt-test ## Quick development cycle (run and test)

.PHONY: full-build
full-build: install setup-db dbt-build docs export ## Complete build from scratch

## Utilities
.PHONY: db-shell
db-shell: ## Open SQLite shell for the database
	sqlite3 $(DB_PATH)

.PHONY: clean
clean: dbt-clean ## Clean generated files
	rm -rf dbt/target/
	rm -f $(DATA_DIR)/transactions.csv

.PHONY: check-env
check-env: ## Check environment and database status
	@echo "Environment Status:"
	@echo "Database exists: $$(if [ -f "$(DB_PATH)" ]; then echo "Yes"; else echo "No"; fi)"
	@echo "Data directory: $$(if [ -d "$(DATA_DIR)" ]; then echo "Exists"; else echo "Missing"; fi)"
	@echo "Docs directory: $$(if [ -d "$(DOCS_DIR)" ]; then echo "Exists"; else echo "Missing"; fi)"
