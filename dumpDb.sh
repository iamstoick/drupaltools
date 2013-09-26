#!/bin/bash

# A script that backup mysql database using `mysqldump` utility.
# Gerald Villorente 2013

# How to use:
# Make sure that the this script is executable. If not then you just need to
# add execute permission by doing this "chmod +x dumpDb.sh".
# Run the script as normal user and supply the database name(s) as parameter.
# Ex: ./dumpDb.sh mydatabasename1 mydatabasename2 mydatabasename3

# For security.
# Place your mysql creds somewhere else (txt file).

# TODO:
# 1. Support multiple database backup. (Done)
# 2. Support remote backup over SSH tunnel.
# 3. Support by-date backup. This is useful when doing daily backup and not
#    overwrite the existing file. (Done)

# What this script do?
# Backup database in a specified directory in a compressed format. This script
# also support multiple database backup per execution.

# Initialize the target directory.
HOMEDIR=$( getent passwd "$USER" | cut -d: -f6 )
TARGETDIR="SQLBackups"
BACKUPDIRECTORY=$HOMEDIR/$TARGETDIR
if [ ! -d "$BACKUPDIRECTORY" ]; then
    mkdir $BACKUPDIRECTORY
fi
DBUSER=$(sudo cat /var/secret/key | grep 'DBUSER' | cut -c8-)
DBPASS=$(sudo cat /var/secret/key | grep 'DBPASS' | cut -c8-)
DBHOST=$(sudo cat /var/secret/key | grep 'DBHOST' | cut -c8-)

# Notify the user.
echo "Running mysqldump utility..."
echo ""

# Dump the database(s).
for databasename in "$@"
do
    mysqldump -h$DBHOST -u$DBUSER -p$DBPASS $databasename | gzip > $BACKUPDIRECTORY/$databasename-`date +%d-%m-%y`.sql.gz
done

# Notify that the dump is done.
echo "Backup done."
