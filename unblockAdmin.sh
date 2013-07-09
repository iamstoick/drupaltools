#!/bin/bash

# Use this script to unblock admin account
# (uid == 1) when blocked due to wrong password
# given more than 5 attempt

drush sqlq "DELETE FROM flood WHERE event = 'failed_login_attempt_user' AND identifier LIKE '1-%'";
