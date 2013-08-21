#!/bin/bash

# A simple script that will find which modules implements given hook.
# @param string $1
#  name of the hook

# Usage: ./hookImplementatorScanner.sh menu
# Where 'menu' is hook_menu.

drush ev "print_r(module_implements('$1'))"
