#!/usr/bin/env bash
#
# @file
# deploy_custom_modules.sh
#
# @description
# Enable custom and featurized modules.
#
# @author
# Gerald Villorente
#
# @info
# Make this file executable. Folders name must be `custom` and `featurized`.
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
# If invoked as ./scripts/deploy_custom_modules.sh.
if [ "$endpath" == "all" ]; then
  cd modules
fi
# Check if custom folder exists.
if [ -d "custom" ]; then
  customFolder="custom"
else
  echo "Cannot find the target directory."
  exit
fi

echo "Deploying custom modules..."

# Navigate to $customFolder.
cd $customFolder
for d in * ; do
  if [ -d "$d" ]; then
    drush en $d -y
  fi
done

# Navigate back to parent folder.
cd ..

# Check if featurized folder exists.
if [ -d "featurized" ]; then
  featurizedFolder="featurized"
else
  echo "Cannot find the target directory."
  exit
fi

echo "Deploying featurized modules..."

# Navigate to $customFolder.
cd $featurizedFolder
for d in * ; do
  if [ -d "$d" ]; then
    drush en $d -y
  fi
done

echo "Reverting all features..."
drush fra -y

echo "Clearing all caches..."
drush cc all

echo "Deployment of custom and featurized modules done!"

