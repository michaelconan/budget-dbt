#!/bin/bash

# fix-lint.sh
# Run SQLFluff fix and lint on all SQL files in the dbt project
# Usage: ./fix-lint.sh

# Auto-fix SQL files in the dbt project
pipenv run sqlfluff fix dbt/

# Lint SQL files in the dbt project
pipenv run sqlfluff lint dbt/