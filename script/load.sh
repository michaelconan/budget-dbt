#!/bin/bash

# load.sh
# Load transaction exports to SQLite raw tables for dbt

DB="db/etl.db"

declare -A data_paths

# table / data export path mapping
data_paths["raw_revolut__personal"]="/revolut/personal"
data_paths["raw_revolut__spouse"]="/revolut/spouse"
data_paths["raw_revolut__joint"]="/revolut/joint"
data_paths["raw_bofa__activity"]="/bofa"

# truncate and load each table
for key in "${!data_paths[@]}"; do
    path="${data_paths[$key]}"
    echo "loading $key from $path"
    # truncate table
    sqlite3 $DB "DELETE FROM $key"
    # import data from each file
    for file in data${path}/*.csv; do
        sqlite3 $DB ".import $file $key --csv --skip 1"
    done
done