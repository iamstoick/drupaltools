#!/bin/bash

# A script that backup mysql database using `mysqldump` utility.
# Gerald Villorente 2013

# How to use:
# Make sure that the this script is executable. If not then you just need to
# add execute permission by doing this "chmod +x dumpDb.sh".
# Run the script as normal user and supply the database name as parameter.
# Ex: ./dumpDb.sh mydatabasename

# TODO:
# 1. Support multiple database backup. (Done)
# 2. Support remote backup over SSH tunnel.
# 3. Support by-date backup. This is useful when doing daily backup and not
#    overwrite the existing file. (Done)

# Initialize the options.
HOMEDIR=$( getent passwd "$USER" | cut -d: -f6 )
TARGETDIR="SQLBackup"
BACKUPDIRECTORY=$HOMEDIR/$TARGETDIR
if [ -d "$BACKUPDIRECTORY" ]; then
    echo $BACKUPDIRECTORY
else
  mkdir $BACKUPDIRECTORY
fi
DBUSER=root
DBPASSWORD=password
DBHOST=localhost
# DBNAME=$1

# Notify the user.
echo "Running mysqldump utility..."
echo ""

# Dump the database(s).
for databasename in "$@"
do
    mysqldump -h$DBHOST -u$DBUSER -p$DBPASSWORD $databasename | gzip > $BACKUPDIRECTORY/$databasename-`date +%d-%m-%y`.sql.gz
done

# Notify that the dump is done.
echo "Backup done."

