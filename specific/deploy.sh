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
# @param string -s
# The scope of the script. Either deploy all (all the scripts)
# or deploy the common.sh only.
#
# @example
# ./script/deploy.sh -s all
#   This will run all scripts inside scripts directory.
# ./script/deploy.sh
#   This will run the common.sh script only.

bold=`tput bold`
normal=`tput sgr0`

# Include other scripts.
SCRIPT_DIR="${BASH_SOURCE%/*}"

# Check if Drush exists.
hash drush 2>/dev/null
if [ $? -eq 1 ]; then
  echo "${bold}[deploy.sh]${normal}  Drush is not available."
  exit
fi

# Check if Drupal is installed.
# Check if user 1 exists.
drush uinf 1 >& /dev/null
if [ "$?" -eq "1" ]; then
  echo "${bold}[deploy.sh]${normal}  Drupal is not installed! Please install it first."
  exit
else
  echo "${bold}[deploy.sh]${normal}  Running deployment scripts..."
  if [[ ! -d "$SCRIPT_DIR" ]]; then
    SCRIPT_DIR="$PWD";
  fi

  # Get options.
  while getopts s: opt; do
    case "${opt}" in
      s)
        SCOPE=${OPTARG}
        ;;
      \?)
        echo "${bold}[deploy.sh]${normal}  Invalid option: -$OPTARG" 2>&1
        exit 1
        ;;
    esac
  done

  if [ "$SCOPE" == "all" ]; then
    "$SCRIPT_DIR/deploy_contrib_modules_and_theme.sh"

    # Clear all Drush caches. Make sure that needed commands
    # by the next script is available.
    drush cc drush

    "$SCRIPT_DIR/deploy_custom_modules.sh"
    "$SCRIPT_DIR/post-install.sh"
    "$SCRIPT_DIR/common.sh"
  else
    echo "${bold}[deploy.sh]${normal}  Running common.sh..."
    "$SCRIPT_DIR/common.sh"
  fi
fi
