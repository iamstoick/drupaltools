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

bold=`tput bold`
normal=`tput sgr0`

# Include other scripts.
SCRIPT_DIR="${BASH_SOURCE%/*}"

# Check if Drush exists.
hash drush 2>/dev/null
if [ $? -eq 1 ]; then
  echo "${bold}[deploy_contrib_modules_and_theme.sh]${normal}  Drush is not available."
  exit
fi

# Check if Drupal is installed.
# Check if user 1 exists.
drush uinf 1 >& /dev/null
if [ "$?" -eq "1" ]; then
  echo "${bold}[deploy_contrib_modules_and_theme.sh]${normal}  Drupal is not installed! Please install it first."
  exit
else
  echo "${bold}[deploy_contrib_modules_and_theme.sh]${normal}  Enabling contrib modules and needed themes..."
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
  echo "${bold}[deploy_contrib_modules_and_theme.sh]${normal}  Cannot find the target directory."
  exit
fi

echo "${bold}[deploy_contrib_modules_and_theme.sh]${normal}  Deploying contrib modules..."

# Navigate to $devFolder.
cd $contribFolder
for d in * ; do
  if [ -d "$d" ]; then
    if [ "$d" == 'features_extra' ]; then
      drush en fe_block -y
      drush en fe_nodequeue -y
    else
      drush en $d -y
    fi
  fi
done

echo "${bold}[deploy_contrib_modules_and_theme.sh]${normal}  Deploying admin themes..."
drush en rubik -y
drush vset admin_theme rubik

if [[ ! -d "$SCRIPT_DIR" ]]; then
  SCRIPT_DIR="$PWD";
fi
"$SCRIPT_DIR/common.sh"

echo "${bold}[deploy_contrib_modules_and_theme.sh]${normal}  Deployment of contrib modules and themes done!"

