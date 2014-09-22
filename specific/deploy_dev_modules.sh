#!/usr/bin/env bash
#
# @file
# deploy_dev_modules.sh
#
# @description
# Enable the modules used for development.
#
# @author
# Gerald Villorente
#
# @info
# Make this file executable. Folder name must be `development` or `dev`.
# Expected location of this script is at `sites/all/modules/scripts`.
# This script expects that the `modules` directory structure is something
# like this:
#
# modules
# -- contrib
# -- custom
# -- development OR dev
# -- featurized
# -- scripts
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
  echo "Running deployment script..."
fi

# Navigate to parent directory.
cd ..
endpath=$(basename $(pwd))
# If invoked as ./scripts/deploy_dev_modules.sh.
if [ "$endpath" == "all" ]; then
  cd modules
fi
# Check if development or dev folder exists.
if [ -d "development" ]; then
  devFolder="development"
elif [ -d "dev" ]; then
  devFolder="dev"
else
  echo "Cannot find the target directory."
  exit
fi

echo "Enabling custom modules..."

# Navigate to $devFolder.
cd $devFolder
for d in * ; do
  if [ -d "$d" ]; then
    drush en $d -y
  fi
done
# Get rid of permission error with devel_themer.
if [ -d "devel_themer" ]; then
  sudo chmod 777 -R /tmp/devel_themer
fi

if [[ ! -d "$SCRIPT_DIR" ]]; then
  SCRIPT_DIR="$PWD";
fi
"$SCRIPT_DIR/common.sh"

echo "Deployment done!"
