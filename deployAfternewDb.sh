# Run this script after importing new database.

# Travel deployment in local machine.
drush cc all
drush vset cdn_status 0 -y
drush en stage_file_proxy -y
drush en varnish -y
drush en context_ui -y
drush en views_ui -y
# Drop cache_coder table.
drush sqlq "DROP TABLE cache_coder;"
drush cc all
drush en coder -y
drush en coder_review -y
drush vset file_temporary_path /tmp
drush sql-query "INSERT INTO role_permission (rid, permission, module) VALUES (3, 'administer contexts', 'context_ui');"
drush sql-query "INSERT INTO role_permission (rid, permission, module) VALUES (3, 'administer varnish', 'varnish');"
drush vset varnish_version 3 -y
drush vset varnish_control_key 3 0682c253-f57a-4e33-8ad2-ac8129bae7d7 -y
drush cc all
drush fra -y
