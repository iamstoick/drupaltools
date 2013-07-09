#!/bin/bash

# Export database with date in filename.

drush sql-dump --result-file="backup_`date +%d-%m-%y`.sql" --gzip
