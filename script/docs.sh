#!/bin/bash
# docs.sh
# Generate static documentation for dbt project
# Usage: ./docs.sh

# Generate static documentation for dbt project
dbt docs generate --static

# Copy the generated static documentation to the docs directory
index_path="docs/index.html"
cp dbt/target/static_index.html docs/index.html
echo "Static documentation generated at $index_path"
