#!/usr/bin/env bash
#
# @file
# enable_dev_modules.sh
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
# Navigate to parent directory.
cd ..
endpath=$(basename $(pwd))
# If invoked as ./scripts/enable_dev_modules.sh.
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
echo "Deployment done!"
