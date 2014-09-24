#!/usr/bin/env bash
#
# @file
# common.sh
#
# @description
# Perform common routing of Drupal depoyment.
#
# @author
# Gerald Villorente
#
# @info
# Make this file executable. This script deploy updates via hook_update_N,
# clear all caches, and reverts all features.
#
# @depedencies
# This script requires Drush.
#

bold=`tput bold`
normal=`tput sgr0`

echo "${bold}[common.sh]${normal}  Running update.php..."
drush updb -y

# Check Features module if it is installed.
features_status=$(drush sql-query "SELECT status FROM system WHERE name='features'" 2>&1)
if [ "$features_status" == "1" ]; then
  echo "${bold}[common.sh]${normal}  Reverting features..."
  drush fra -y
fi

echo "${bold}[common.sh]${normal}  Clearing all caches..."
drush cc all

echo "${bold}[common.sh]${normal}  Deployment done!"
