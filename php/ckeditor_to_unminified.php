<?php

// Define the root directory.
define('DRUPAL_ROOT', '/home/gerald/Dev/CNNTravel/cnngod7/html/');
// Include database utility.
require_once DRUPAL_ROOT . '/includes/database/database.inc';
// Include the bootstrap file.
require_once DRUPAL_ROOT . '/includes/bootstrap.inc';
// Set the bootstrap to database.
drupal_bootstrap(DRUPAL_BOOTSTRAP_DATABASE);
// Set the active database.
db_set_active('default');

// Retrieve the ckeditor settings.
$result = db_query("SELECT settings FROM {ckeditor_settings} WHERE name = :name", array(':name' => 'CKEditor Global Profile'))->fetchField();
// Unserialize the result.
$settings = unserialize($result);

// Replace the ckeditor path with unminified version.
if ($settings['ckeditor_path'] == '%l/ckeditor') {
  $settings['ckeditor_path'] = '%b/sites/local.travel.cnn.com/libraries/ckeditor';
}

// Serialize the settings.
$settings = serialize($settings);

// Update the ckeditor settings.
db_update('ckeditor_settings')
    ->fields(array(
      'settings' => $settings,
    ))
    ->condition('name', 'CKEditor Global Profile', '=')
    ->execute();
?>
