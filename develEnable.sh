drush en devel -y
drush sql-query "INSERT INTO role_permission (rid, permission, module) VALUES (3, 'access devel information', 'devel')"
drush vset devel_query_display 0
