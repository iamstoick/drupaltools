#!/bin/bash

# Renew database
# Usage:
# ./renewDb.sh /path/to/db.sql

drush sql-drop
if [ -f "$1" ]; then
  drush sql-cli < $1
else
  echo "The sql file does not exist."
fi
