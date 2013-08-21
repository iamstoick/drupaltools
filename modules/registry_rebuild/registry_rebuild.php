<?php

/**
 * Root directory of Drupal installation. Note that you can change this
 * if you need to. It just has to point to the actual root. This assumes
 * that the php file is being run in sites/all/modules/registry_rebuild.
 */

ini_set('memory_limit', -1);
define('DRUPAL_ROOT', define_drupal_root());
chdir(DRUPAL_ROOT);
print "DRUPAL_ROOT is " . DRUPAL_ROOT . ".<br/>\n";
define('MAINTENANCE_MODE', 'update');

global $_SERVER;
$_SERVER['REMOTE_ADDR'] = 'nothing';

global $include_dir;
$include_dir = DRUPAL_ROOT . '/includes';
$module_dir = DRUPAL_ROOT . '/modules';
// Use core directory if it exists.
if (file_exists(DRUPAL_ROOT . '/core/includes/bootstrap.inc')) {
  $include_dir = DRUPAL_ROOT . '/core/includes';
  $module_dir = DRUPAL_ROOT . '/core/modules';
}

$includes = array(
  $include_dir . '/bootstrap.inc',
  $include_dir . '/common.inc',
  $include_dir . '/database.inc',
  $include_dir . '/schema.inc',
  $include_dir . '/actions.inc',
  $include_dir . '/entity.inc',
  $module_dir . '/entity/entity.module',
  $module_dir . '/entity/entity.controller.inc',
  $module_dir . '/system/system.module',
  $include_dir . '/database/query.inc',
  $include_dir . '/database/select.inc',
  $include_dir . '/registry.inc',
  $include_dir . '/module.inc',
  $include_dir . '/menu.inc',
  $include_dir . '/file.inc',
  $include_dir . '/theme.inc',
);

if (function_exists('registry_rebuild')) { // == D7
  $cache_lock_path = DRUPAL_ROOT . '/'. variable_get('lock_inc', 'includes/lock.inc');
  // Ensure that the configured lock.inc really exists at that location and
  // is accessible. Otherwise we use the core lock.inc as fallback.
  if (!is_readable($cache_lock_path)) {
    print "Could not load configured variant of lock.inc. Use core implementation as fallback.<br/>\n";
    $cache_lock_path = DRUPAL_ROOT . '/includes/lock.inc';
  }
  $includes[] = $cache_lock_path;
}
elseif (!function_exists('cache_clear_all')) { // D8+
  // TODO
  // http://api.drupal.org/api/drupal/namespace/Drupal!Core!Lock/8
}
// In Drupal 6 the configured lock.inc is already loaded during
// DRUSH_BOOTSTRAP_DRUPAL_DATABASE

foreach ($includes as $include) {
  if (file_exists($include)) {
    require_once($include);
  }
}

print "Bootstrapping to DRUPAL_BOOTSTRAP_SESSION<br/>\n";
drupal_bootstrap(DRUPAL_BOOTSTRAP_SESSION);

registry_rebuild_rebuild();

/**
 * Find the drupal root directory by looking in parent directories.
 * If unable to discover it, fail and exit.
 */
function define_drupal_root() {
  // This is the smallest number of directories to go up: from /sites/all/modules/registry_rebuild.
  $parent_count = 4;
  // 8 seems reasonably far to go looking up.
  while ($parent_count < 8) {
    $dir = realpath(getcwd() . str_repeat('/..', $parent_count));
    if (file_exists($dir . '/index.php')) {
      return $dir;
    }
    $parent_count++;
  }
  print "Failure: Unable to discover DRUPAL_ROOT. You may want to explicitly define it near the top of registry_rebuild.php";
  exit(1);
}

/**
 * Before calling this we need to be bootstrapped to DRUPAL_BOOTSTRAP_SESSION.
 */
function registry_rebuild_rebuild() {
  // This section is not functionally important. It's just getting the
  // registry_parsed_files() so that it can report the change.
  // Note that it works with Drupal 7 only.
  if (function_exists('registry_rebuild')) {
    $connection_info = Database::getConnectionInfo();
    $driver = $connection_info['default']['driver'];
    global $include_dir;
    require_once $include_dir . '/database/' . $driver . '/query.inc';
    $parsed_before = registry_get_parsed_files();
  }

  if (function_exists('registry_rebuild')) { // == D7
    cache_clear_all('lookup_cache', 'cache_bootstrap');
    cache_clear_all('variables', 'cache_bootstrap');
    cache_clear_all('module_implements', 'cache_bootstrap');
    print "Bootstrap caches have been cleared in DRUPAL_BOOTSTRAP_SESSION<br/>\n";
  }
  elseif (!function_exists('cache_clear_all')) { // D8+
    cache('bootstrap')->deleteAll();
    print "Bootstrap caches have been cleared in DRUPAL_BOOTSTRAP_SESSION<br/>\n";
  }

  if (function_exists('registry_rebuild')) {
    print "Doing registry_rebuild() in DRUPAL_BOOTSTRAP_SESSION<br/>\n";
    registry_rebuild();  // Drupal 7 compatible only
  }
  elseif (function_exists('module_rebuild_cache')) {
    print "Doing module_rebuild_cache() in DRUPAL_BOOTSTRAP_SESSION<br/>\n";
    module_rebuild_cache();  // Drupal 5 and 6 compatible only
  }
  else {
    print "Doing system_rebuild_module_data() in DRUPAL_BOOTSTRAP_SESSION<br/>\n";
    system_rebuild_module_data();  // Drupal 8 compatible
  }

  print "Bootstrapping to DRUPAL_BOOTSTRAP_FULL<br/>\n";
  drupal_bootstrap(DRUPAL_BOOTSTRAP_FULL);
  db_truncate('cache');

  if (function_exists('registry_rebuild')) {
    print "Doing registry_rebuild() in DRUPAL_BOOTSTRAP_FULL<br/>\n";
    registry_rebuild();  // Drupal 7 compatible only
  }
  elseif (function_exists('module_rebuild_cache')) {
    print "Doing module_rebuild_cache() in DRUPAL_BOOTSTRAP_FULL<br/>\n";
    module_rebuild_cache();  // Drupal 5 and 6 compatible only
  }
  else {
    print "Doing system_rebuild_module_data() in DRUPAL_BOOTSTRAP_FULL<br/>\n";
    system_rebuild_module_data();  // Drupal 8 compatible
  }

  if (function_exists('registry_rebuild')) { // Drupal 7 compatible only
    $parsed_after = registry_get_parsed_files();
    // Remove files which don't exist anymore.
    $filenames = array();
    foreach ($parsed_after as $filename => $file) {
      if (!file_exists($filename)) {
        $filenames[] = $filename;
      }
    }
    if (!empty($filenames)) {
      db_delete('registry_file')
        ->condition('filename', $filenames)
        ->execute();
      db_delete('registry')
        ->condition('filename', $filenames)
        ->execute();
      print("Deleted " . count($filenames) . ' stale files from registry manually.');
    }
    $parsed_after = registry_get_parsed_files();
    print "Flushing all caches<br/>\n";
    drupal_flush_all_caches();
    print "There were " . count($parsed_before) . " files in the registry before and " . count($parsed_after) . " files now.<br/>\n";
    print "If you don't see any crazy fatal errors, your registry has been rebuilt.<br/>\n";
  }
  else {
    print "Flushing all caches<br/>\n";
    drupal_flush_all_caches();
    print "If you don't see any crazy fatal errors, your registry has been rebuilt.<br/>\n";
  }
}
