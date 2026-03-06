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

.PHONY: init
init: ## Initialize DuckDB database
	@echo "Initializing DuckDB database..."
	@./script/init_db.sh $(DB_PATH)

.PHONY: load
load: ## Load data into DuckDB
	@echo "Loading data into DuckDB..."
	@./script/load.sh $(DB_PATH) $(DATA_DIR)

.PHONY: clean
clean: ## Clean dbt artifacts and database
	@echo "Cleaning dbt artifacts..."
	$(PIPENV) dbt clean
	@echo "Cleaning database..."
	@rm -f $(DB_PATH)
	@rm -rf db/temp

.PHONY: dbt-deps
dbt-deps: ## Install dbt packages
	@echo "Installing dbt packages..."
	$(PIPENV) dbt deps

.PHONY: dbt-run
dbt-run: ## Run dbt models
	@echo "Running dbt models..."
	$(PIPENV) dbt run

.PHONY: dbt-seed
dbt-seed: ## Run dbt seed
	@echo "Running dbt seed..."
	$(PIPENV) dbt seed

.PHONY: dbt-test
dbt-test: ## Run dbt tests
	@echo "Running dbt tests..."
	$(PIPENV) dbt test

.PHONY: test-local
test-local: ## Run local tests
	$(PIPENV) dbt deps; \
	$(PIPENV) dbt seed --target local; \
	$(PIPENV) dbt run --target local; \
	$(PIPENV) dbt test --target local; \
	$(PIPENV) dbt docs generate --target local

.PHONY: dbt-build
dbt-build: ## Run dbt build (seed, run, test)
	$(PIPENV) dbt build

.PHONY: dump-data
dump-data: ## Export transaction data to CSV
	@echo "Exporting transaction data..."
	@mkdir -p $(DATA_DIR)
	duckdb $(DB_PATH) "COPY transactions TO '$(DATA_DIR)/transactions.csv'"
	@echo "Transaction data exported to $(DATA_DIR)/transactions.csv"

.PHONY: dump-vendors
dump-vendors: ## Export vendor category mapping to CSV
	@echo "Exporting vendors for categorisation..."
	@duckdb $(DB_PATH) "COPY (SELECT * FROM category_audit ORDER BY 1,2 ASC) TO '$(SEEDS_DIR)/vendor_category_mapping.csv'"

.PHONY: categorise-vendors
categorise-vendors: ## Run Gemini to categorise TBD vendors
	@echo "Categorising vendors with Gemini..."
	@echo "@dbt/seeds/vendor_category_mapping.csv Replace all TBD categories" > $(TMP_PROMPT)
	@echo "with an appropriate category from the list of categories in" >> $(TMP_PROMPT)
	@echo "@dbt/dbt_project.yml and save the file to the same location." >> $(TMP_PROMPT)
	@cat $(TMP_PROMPT) | gemini
	@rm $(TMP_PROMPT)
	@echo "Categorised TBD vendors"

.PHONY: categorise
categorise: dump-vendors categorise-vendors ## Run the full vendor categorisation workflow
	@echo "Categorisation workflow completed."

.PHONY: doc-coverage
doc-coverage: ## Compute dbt doc coverage
	@pipenv run dbt-coverage compute doc

.PHONY: test-coverage
test-coverage: ## Compute dbt test coverage
	@pipenv run dbt-coverage compute test

## Documentation (from docs.sh)
.PHONY: docs
docs: ## Generate static dbt documentation
	@echo "Generating static documentation..."
	@$(PIPENV) dbt docs generate --static
	@mkdir -p $(DOCS_DIR)
	@cp dbt/target/static_index.html $(DOCS_DIR)/index.html
	@echo "Static documentation generated at $(DOCS_DIR)/index.html"

## Code Quality (from fix-lint.sh)
.PHONY: fix-lint
fix-lint: ## Auto-fix and lint SQL files
	@echo "Auto-fixing SQL files..."
	@$(PIPENV) sqlfluff fix dbt/
	@echo "Linting SQL files..."
	@$(PIPENV) sqlfluff lint dbt/

.PHONY: refresh
refresh: load dbt-deps dbt-build ## Reload data and rebuild dbt
	@echo "Refresh completed!"

.PHONY: full-setup
full-setup: init load dbt-deps dbt-run ## Full project setup from scratch
	@echo "Full setup completed!"

.PHONY: dev
dev: test-local dbt-build ## Run development workflow
	@echo "Development workflow completed!"

.PHONY: streamlit-run
streamlit-run: ## Run the streamlit app
	@$(PIPENV) streamlit run apps/budget_dashboard.py

## Utilities
.PHONY: db-shell
db-shell: ## Open DuckDB shell for the database
	@duckdb $(DB_PATH)
