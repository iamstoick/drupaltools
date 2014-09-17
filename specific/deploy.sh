#!/usr/bin/env bash
#
# @file
# deploy.sh
#
# @description
# Deploy changes.
#
# @author
# Gerald Villorente
#
# @info
# Make this file executable. This script deploy code changes and db updates via
# hook_update_N.
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
  exit
else
  echo "Running deployment scripts..."
fi

# Disabling unnecessary blocks in admin theme.
drush_extras_status=$(drush sql-query "SELECT status FROM system WHERE name='drush_extras'" 2>&1)
if [ "$drush_extras_status" -eq "1" ]; then
  drush block-disable --delta=form --module=search --theme=rubik
  drush block-disable --delta=navigation --module=system --theme=rubik
  drush block-disable --delta=powered-by --module=system --theme=rubik
  echo "Form, Navigation, and Powered-by blocks are now disabled in Rubik theme."
fi

echo "Running update.php..."
drush updb -y

echo "Reverting features..."
drush fra -y

echo "Clearing all caches..."
drush cc all

echo "Deployment done!"
