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

bold=`tput bold`
normal=`tput sgr0`

# Include other scripts.
SCRIPT_DIR="${BASH_SOURCE%/*}"

# Check if Drush exists.
hash drush 2>/dev/null
if [ $? -eq 1 ]; then
  echo "${bold}[post-install.sh]${normal}  Drush is not available."
  exit
fi

# Check if Drupal is installed.
# Check if user 1 exists.
drush uinf 1 >& /dev/null
if [ "$?" -eq "1" ]; then
  echo "${bold}[post-install.sh]${normal}  Drupal is not installed! Please install it first."
  exit
else
  echo "${bold}[post-install.sh]${normal}  Running post-install script..."
  # drush dis every_field -y
  # drush pmu every_field -y

  # Disabling unnecessary blocks in admin theme.
  drush_extras_status=$(drush sql-query "SELECT status FROM system WHERE name='drush_extras'" 2>&1)
  if [ "$drush_extras_status" == "1" ]; then
    drush block-disable --delta=form --module=search --theme=rubik
    drush block-disable --delta=navigation --module=system --theme=rubik
    drush block-disable --delta=powered-by --module=system --theme=rubik
    echo "${bold}[post-install.sh]${normal}  Form, Navigation, and Powered-by blocks are now disabled in Rubik theme."
  fi
fi

if [[ ! -d "$SCRIPT_DIR" ]]; then
  SCRIPT_DIR="$PWD";
fi
"$SCRIPT_DIR/common.sh"

echo "${bold}[post-install.sh]${normal}  Deployment done!"
