#!/usr/bin/env bash
#
# @file
# deploy_contrib_modules_and_theme.sh
#
# @description
# Enable contrib modules and themes.
#
# @author
# Gerald Villorente
#
# @info
# Make this file executable. Folder name must be `contrib`.
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

# Check if Drush exists.
hash drush 2>/dev/null
if [ $? -eq 1 ]; then
  echo "Drush is not available."
  exit
fi

# Navigate to parent directory.
cd ..

endpath=$(basename $(pwd))
# If invoked as ./scripts/deploy_contrib_modules_and_theme.sh.
if [ "$endpath" == "all" ]; then
  cd modules
fi
# Check if contrib folder exists.
if [ -d "contrib" ]; then
  contribFolder="contrib"
else
  contribFolder=${PWD##*/}
  echo "Cannot find the target directory."
  exit
fi

echo "Deploying contrib modules..."

# Navigate to $devFolder.
cd $contribFolder
for d in * ; do
  if [ -d "$d" ]; then
    drush en $d -y
  fi
done

echo "Deploying admin themes..."
drush en rubik -y
drush vset admin_theme rubik

echo "Clearing all caches..."
drush cc all

echo "Deployment of contrib modules and themes done!"

