#!/bin/bash

# A script that delete mysql database using `mysqladmin` utility.
# Gerald Villorente 2013

# How to use:
# Make sure that the this script is executable. If not then you just need to
# add execute permission by doing this "chmod +x dropDb.sh".
# Run the script as normal user and supply the database name as parameter.
# Ex: ./dropDb.sh mydatabasename1 mydatabasename2 mydatabasename3

# TODO:
# 1. Support multiple database delete. (Done)
# 2. Support remote deletion over SSH tunnel.

# Initialize the options.
DBUSER=root
DBPASSWORD=password
DBHOST=localhost

# Notify the user.
echo "Running mysqladmin drop utility..."
echo ""

# Drop the database(s).
for databasename in "$@"
do
    mysqladmin -h$DBHOST -u$DBUSER -p$DBPASSWORD drop $databasename
done

# Notify that the drop is done.
echo "Drop done."
