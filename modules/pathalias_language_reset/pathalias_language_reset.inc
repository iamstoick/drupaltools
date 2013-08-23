<?php

/**
 * @file
 * Batch operations callback.
 */


/**
 * Batch operations callback.
 */
function pathalias_language_reset_update(&$context) {
  if (empty($context['sandbox'])) {
    $context['sandbox']['progress'] = 0;
    $context['sandbox']['current_node'] = 0;
    $context['sandbox']['max'] = db_query("SELECT COUNT(DISTINCT ua.pid) FROM {url_alias} ua WHERE ua.language IN ('ko', 'ja', 'zh-hant', 'zh-hans', 'en')")->fetchField();
  }
  // Set the batch limit.
  $limit = 15;
  // Select the source table.
  $query = db_select('url_alias', 'ua');
  $results = $query
    ->fields('ua', array('pid', 'alias', 'source'))
    ->condition('ua.language', array('en', 'zh-hans', 'zh-hant', 'ja', 'ko'), 'IN')
    ->orderBy('ua.pid')
    ->range(0, $limit)
    ->execute();
  foreach ($results as $row) {
    $path = array('source' => $row->source, 'alias' => $row->alias, 'pid' => $row->pid, 'language' => LANGUAGE_NONE);
    path_save($path);
    $context['results'][] = $row->pid . ' : ' . check_plain($row->alias);
    $context['sandbox']['progress']++;
    $context['sandbox']['current_node'] = $row->pid;
    $context['message'] = $row->pid . ' : ' . check_plain($row->alias);
  }
  if ($context['sandbox']['progress'] != $context['sandbox']['max']) {
    $context['finished'] = $context['sandbox']['progress'] / $context['sandbox']['max'];
  }
}


/**
 * Batch finished callback.
 */
function pathalias_language_reset_finished($success, $results, $operations) {
  // The 'success' parameter means no fatal PHP errors were detected. All
  // other error management should be handled using 'results'.
  if ($success) {
    $message = format_plural(count($results), 'One post processed.', '@count posts processed.');
  }
  else {
    $message = t('Finished with an error.');
  }
  drupal_set_message($message);
  // Providing data for the redirected page is done through $_SESSION.
  foreach ($results as $result) {
    $items[] = t('Loaded node %title.', array('%title' => $result));
  }
  $_SESSION['my_batch_results'] = $items;
}
