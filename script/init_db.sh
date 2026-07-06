#!/bin/bash

# init_db.sh
# Initialize DuckDB database and create raw tables for dbt

# Exit immediately if a command exits with a non-zero status.
set -e

DB_PATH=$1

if [ -z "$DB_PATH" ]; then
    echo "Usage: $0 <db_path>"
    echo "Example: $0 db/etl.duckdb"
    exit 1
fi

# Create database directory if it doesn't exist
DB_DIR=$(dirname "$DB_PATH")
mkdir -p "$DB_DIR"

echo "Initializing DuckDB database at $DB_PATH"

# Create database and tables
duckdb "$DB_PATH" << EOF
-- Create raw tables
$(cat ddl/raw_revolut__personal.sql)

$(cat ddl/raw_revolut__spouse.sql)

$(cat ddl/raw_revolut__joint.sql)

$(cat ddl/raw_bofa__activity.sql)

-- Show created tables
SHOW TABLES;
EOF

echo "Database initialization completed successfully!" 