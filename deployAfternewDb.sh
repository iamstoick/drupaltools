#!/bin/bash

# A utility to deploy all local tools after renewing database from production.
# I used this script as Acquia is using internal configurations in the following modules:
# 1. APC
# 2. Memcache
# 3. Varnish
#
# Some of the modules like Coder and Stage File Proxy are used in local development.
#

# Run this script after importing new database.

# Travel deployment in local machine.

# Purge all the cache first
drush cc all

# Disable CDN module
drush vset cdn_status 0 -y

# Enable stage file proxy to replace CDN.
drush en stage_file_proxy -y

# Install Varnish.
drush en varnish -y
drush vset varnish_control_key e5a49203-7234-4a79-b2d5-e09623490166 -y
drush vset varnish_version 3 -y
drush sql-query "INSERT INTO role_permission (rid, permission, module) VALUES (3, 'administer varnish', 'varnish');"

# Install APC module.
drush en apc -y
drush sqlq "INSERT INTO role_permission (rid, permission, module) VALUES (3, 'access apc statistics', 'apc');"

# Install Context UI.
drush en context_ui -y
drush sql-query "INSERT INTO role_permission (rid, permission, module) VALUES (3, 'administer contexts', 'context_ui');"

# Enable Views UI module.
drush en views_ui -y

# Install Memcache Admin.
drush en memcache_admin -y
drush sqlq "INSERT INTO role_permission (rid, permission, module) VALUES (3, 'access slab cachedump', 'memcache_admin');"
# Drop cache_coder table.
drush sqlq "DROP TABLE cache_coder;"
drush cc all

# Install coder review.
drush en coder -y
drush en coder_review -y

# Update temp path
drush vset file_temporary_path /tmp

# Replace Ckeditor with unminified version.
drush php-script --script-path=/home/gerald/Dev/CNNTravel/cnngod7/html/sites/local.travel.cnn.com/php ckeditor_to_unminified

drush cc all

# Revert all features
drush fra -y
drush cc all
