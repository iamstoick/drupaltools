#!/bin/bash

# Export database with date in filename and compress using gzip format. 

drush sql-dump --result-file="backup_`date +%d-%m-%y`.sql" --gzip
