#!/bin/bash

# schema.sh
# Create SQLite raw tables to load transactional data for dbt

DB="db/etl.db"

# run all DDL files
for file in schema/*; do
    echo "executing $file"
    sqlite3 $DB ".read $file"
done