#!/bin/bash

# A script that backup mysql database using `mysqldump` utility.
# Gerald Villorente 2013

# How to use:
# Make sure that the this script is executable. If not then you just need to
# add execute permission by doing this "chmod +x dumpDb.sh".
# Run the script as normal user and supply the database name as parameter.
# Ex: ./dumpDb.sh mydatabasename

# TODO:
# Support multiple database backup.
# Support remote backup over SSH tunnel.

# Initialize the options.
DBUSER=root
DBPASSWORD=password
DBHOST=localhost
DBNAME=$1
BACKUPDIRECTORY=/home/gerald/Projects/SQLBackup

# Notify the user.
echo "Running mysqldump utility..."
echo ""

# Dump the database.
mysqldump -h$DBHOST -u$DBUSER -p$DBPASSWORD $DBNAME | gzip > $BACKUPDIRECTORY/$DBNAME.sql.gz

# Notify that the dump is done.
echo "Backup done."

