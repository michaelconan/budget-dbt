#!/bin/bash

# export.sh
# Export transaction data from dbt model for analytics

DB="db/etl.db"

sqlite3 $DB << EOF
.mode csv
.headers on
.output data/transactions.csv
SELECT * FROM transactions;
.quit
EOF
