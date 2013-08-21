#!/bin/bash

# Count enabled modules.
drush pml --type=module --status=enabled | wc -l
