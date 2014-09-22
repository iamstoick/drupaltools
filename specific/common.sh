#!/usr/bin/env bash
#
# @file
# common.sh
#
# @description
# Perform common routing of Drupal depoyment.
#
# @author
# Gerald Villorente
#
# @info
# Make this file executable. This script deploy updates via hook_update_N,
# clear all caches, and reverts all features.
#
# @depedencies
# This script requires Drush.
#
echo "Running update.php..."
drush updb -y

echo "Reverting features..."
drush fra -y

echo "Clearing all caches..."
drush cc all

echo "Deployment done!"
