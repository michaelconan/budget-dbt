# Budget DBT Project - DuckDB Edition
# Makefile for database operations and dbt workflows

# Database paths
DB_PATH = db/etl.duckdb
DATA_DIR = data
DOCS_DIR = docs
SEEDS_DIR = dbt/seeds
TMP_PROMPT = prompt.txt

# Python environment
UV = uv run
COV_ARGS = --project-dir dbt --run-artifacts-dir dbt/target --output-format markdown

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
install: ## Install Python dependencies using uv
	uv sync

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
	$(UV) dbt clean
	@echo "Cleaning database..."
	@rm -f $(DB_PATH)
	@rm -rf db/temp

.PHONY: dbt-deps
dbt-deps: ## Install dbt packages
	@echo "Installing dbt packages..."
	$(UV) dbt deps

.PHONY: dbt-run
dbt-run: ## Run dbt models
	@echo "Running dbt models..."
	$(UV) dbt run

.PHONY: dbt-seed
dbt-seed: ## Run dbt seed
	@echo "Running dbt seed..."
	$(UV) dbt seed

.PHONY: dbt-test
dbt-test: ## Run dbt tests
	@echo "Running dbt tests..."
	$(UV) dbt test

.PHONY: test-local
test-local: ## Run local tests
	$(UV) dbt deps; \
	$(UV) dbt build --target local --exclude "source:*"; \
	$(UV) dbt compile --write-catalog --target local

.PHONY: dbt-build
dbt-build: ## Run dbt build (seed, run, test)
	$(UV) dbt build

.PHONY: dbt-eval
dbt-eval: ## Run dbt project evaluator tests
	$(UV) dbt build --select package:dbt_project_evaluator --target local

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
	@$(UV) dbt-coverage compute doc $(COV_ARGS)

.PHONY: test-coverage
test-coverage: ## Compute dbt test coverage
	@$(UV) dbt-coverage compute test $(COV_ARGS)

## Documentation
.PHONY: docs
docs: ## Generate MkDocs wiki and dbt documentation (v1 legacy)
	@echo "Generating dbt documentation with dbt v1..."
	@uvx --from dbt-core~=1.11.0 --with dbt-duckdb~=1.10.0 dbt docs generate --project-dir dbt --profiles-dir dbt --target local
	@echo "Building MkDocs wiki..."
	@$(UV) mkdocs build --clean
	@echo "Integrating dbt docs into wiki..."
	@mkdir -p site/dbt
	@curl -s -L https://raw.githubusercontent.com/dbt-labs/dbt-core/v1.9.0/core/dbt/task/docs/index.html -o site/dbt/index.html
	@cp dbt/target/catalog.json site/dbt/
	@cp dbt/target/manifest.json site/dbt/
	@cp docs/.nojekyll site/
	@echo "Documentation generated at site/index.html"

.PHONY: docs-v2
docs-v2: ## Generate and serve dbt v2 documentation
	@echo "Generating dbt v2 documentation..."
	@$(UV) dbt compile --write-index --project-dir dbt --profiles-dir dbt --target local
	@$(UV) dbt docs serve --project-dir dbt --profiles-dir dbt --target local

## Code Quality (from fix-lint.sh)
.PHONY: fix-lint
fix-lint: ## Auto-format and lint SQL files
	@echo "Formatting SQL files..."
	@$(UV) sqlfmt dbt/
	@echo "Auto-fixing SQL files (linting)..."
	@$(UV) sqlfluff fix dbt/
	@echo "Linting SQL files..."
	@$(UV) sqlfluff lint dbt/

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
	@$(UV) streamlit run apps/budget_dashboard.py

## Utilities
.PHONY: db-shell
db-shell: ## Open DuckDB shell for the database
	@duckdb $(DB_PATH)
