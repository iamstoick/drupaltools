#!/usr/bin/env bash
#
# @file
# post-install.sh
#
# @description
# Remove unnecessary modules and data from Drupal core.
#
# @author
# Gerald Villorente
#
# @info
# Make this file executable. This script removes all configuration that came
# from Drupal core.
#
# @depedencies
# This script requires Drush.
#
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
else
  echo "Running post-install script..."
  drush dis every_field -y
  drush pmu every_field -y
fi

echo "Running update.php..."
drush updb -y

echo "Reverting features..."
drush fra -y

echo "Clearing all caches..."
drush cc all

echo "Deployment done!"
