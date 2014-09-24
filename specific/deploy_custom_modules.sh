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

bold=`tput bold`
normal=`tput sgr0`

# Check if Drush exists.
hash drush 2>/dev/null
if [ $? -eq 1 ]; then
  echo "${bold}[deploy_custom_modules.sh]${normal}  Drush is not available."
  exit
fi

# Check if Drupal is installed.
# Check if user 1 exists.
drush uinf 1 >& /dev/null
if [ "$?" -eq "1" ]; then
  echo "${bold}[deploy_custom_modules.sh]${normal}  Drupal is not installed! Please install it first."
  exit
else
  echo "${bold}[deploy_custom_modules.sh]${normal}  Running deployment script..."
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
  echo "${bold}[deploy_custom_modules.sh]${normal}  Cannot find the target directory."
  exit
fi

echo "${bold}[deploy_custom_modules.sh]${normal}  Deploying custom modules..."

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
  echo "${bold}[deploy_custom_modules.sh]${normal}  Cannot find the target directory."
  exit
fi

echo "${bold}[deploy_custom_modules.sh]${normal}  Deploying featurized modules..."

# Navigate to $customFolder.
cd $featurizedFolder
for d in * ; do
  if [ -d "$d" ]; then
    drush en $d -y
  fi
done

# Run update.php
echo "${bold}[deploy_custom_modules.sh]${normal}  Running update.php..."
drush updb -y

# Check Features module if it is installed.
features_status=$(drush sql-query "SELECT status FROM system WHERE name='features'" 2>&1)
if [ "$features_status" == "1" ]; then
  echo "${bold}[deploy_custom_modules.sh]${normal}  Reverting all features..."
  drush fra -y
fi

echo "${bold}[deploy_custom_modules.sh]${normal}  Clearing all caches..."
drush cc all

echo "${bold}[deploy_custom_modules.sh]${normal}  Deployment of custom and featurized modules done!"

