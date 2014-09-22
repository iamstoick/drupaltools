#!/usr/bin/env bash
#
# @file
# reset.sh
#
# @description
# Reset Drupal instance. This means reinstall Drupal again.
#
# @author
# Gerald Villorente
#
# Include other scripts.
SCRIPT_DIR="${BASH_SOURCE%/*}"

# Get Drupal root directory.
root=$(drush status | grep "Drupal root" | cut -c37- | tr -d ' ')
settings_path=$(drush status | grep "Site path" | cut -c37- | tr -d ' ')

# Get the user who run Apache2.
user=$(ps -ef | egrep '(apache2|httpd)' | grep -v `whoami` | grep -v root | head -n1 | awk '{print $1}')

# Check if Drush exists.
hash drush 2>/dev/null
if [ $? -eq 1 ]; then
  echo "Drush is not available."
  exit
fi

# Check if Drupal is installed.
# Check if user 1 exists.
drush uinf 1 >& /dev/null
if [ "$?" -eq "1" ]; then
  echo "Drupal is not installed! Please install it first."
  exit
else
  echo "Dropping all tables in the database..."
  drush sql-drop -y
  if [ -d "$root" ];  then
    path="$root/$settings_path"
    cd $path
    echo "Replacing settings.php with default.settings.php..."
    rm settings.php
    cp default.settings.php settings.php
    sudo chown $user settings.php
  fi
fi
echo "Done resetting. Please run the installation again."
