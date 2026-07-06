#!/bin/bash

# load.sh
# Load transaction exports to DuckDB raw tables for dbt

# Exit immediately if a command exits with a non-zero status.
set -e

DB_PATH=$1
DATA_DIR=$2

if [ -z "$DB_PATH" ] || [ -z "$DATA_DIR" ]; then
    echo "Usage: $0 <db_path> <data_dir>"
    exit 1
fi

declare -A data_paths
data_paths["raw_revolut__personal"]="/revolut/personal"
data_paths["raw_revolut__spouse"]="/revolut/spouse"
data_paths["raw_revolut__joint"]="/revolut/joint"
data_paths["raw_bofa__activity"]="/bofa"

for key in "${!data_paths[@]}"; do
    path="${data_paths[$key]}"
    echo "Loading $key from $path"
    
    # Clear existing data
    duckdb "$DB_PATH" "DELETE FROM $key;"
    
    # Load CSV files
    for file in "$DATA_DIR$path"/*.csv; do
        if [ -f "$file" ]; then
            echo "Loading $file into $key"
            duckdb "$DB_PATH" "COPY $key FROM '$file' (AUTO_DETECT TRUE, HEADER FALSE, SKIP 1);"
        fi
    done
done

echo "Data loading completed successfully!"
