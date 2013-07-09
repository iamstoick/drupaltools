drush vset cdn_status 0 -y
drush en stage_file_proxy -y
drush en context_ui -y
drush en views_ui -y
drush en coder -y
drush en coder_review -y
drush vset file_temporary_path /tmp
drush solr-vset --yes apachesolr_read_only 1
drush sql-query "INSERT INTO role_permission (rid, permission, module) VALUES (3, 'administer contexts', 'context_ui')"
drush cc all
drush fra -y
