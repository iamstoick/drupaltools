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

# Include other scripts.
SCRIPT_DIR="${BASH_SOURCE%/*}"

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
  if [[ ! -d "$SCRIPT_DIR" ]]; then
    SCRIPT_DIR="$PWD";
  fi
  "$SCRIPT_DIR/deploy_contrib_modules_and_theme.sh"

  # Clear all Drush caches. Make sure that needed commands
  # by the next script is available.
  drush cc drush

  "$SCRIPT_DIR/deploy_custom_modules.sh"
  "$SCRIPT_DIR/post-install.sh"
  "$SCRIPT_DIR/common.sh"
fi
