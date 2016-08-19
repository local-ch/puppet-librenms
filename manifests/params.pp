# == Class: librenms::params
#
# Parameter class for libremms
#
# === Authors
#
# Andre Timmermann librenms@darktim.de
#
# === Copyright
#
# Copyright (C) 2016 Andre Timmermann
#
class librenms::params {
  # the install direectory for the git checkout
  $install_dir = '/opt/librenms'

  # the git repository to be used.
  $git_source = 'https://github.com/librenms/librenms.git'

  # if you want to use librenms::mysql to set up the database
  $configure_mysql = true

  # if you want to use librenms::cron to set up the cronjobs
  $configure_cron = true

  # if you want to use librenms::add_device collector so that
  # all hosts with class librenms::device will be added to LibreNMS
  $collector = true

  # user and group to be created/used by LibreNMS
  $librenms_user = 'librenms'
  $librenms_group = 'librenms'

  # these are used by librenms::mysql
  $mysql_db = 'librenms'
  $mysql_user = 'librenms'
  $mysql_pass = ''

  # these are used by librenms::cron
  # The values are taken from the file librenms.nonroot.cron inside of the checkout

  # By default, the cron job runs poller-wrapper.py with 16 threads.
  # The current recommendation is to use 4 threads per core as a rule of thumb.
  $poller_threads = '12'

  # when the poller-wrapper should run
  $cron_poller_wrapper_minute = '*/5'
  $cron_poller_wrapper_hour = '*'

  # discover all new devices
  $cron_discover_new_minute = '*/5'
  $cron_discover_new_hour = '*'

  # (re)-discover ALL devices
  $cron_discover_all_minute = '33'
  $cron_discover_all_hour = '*/6'

  # the daily cronjobs
  $cron_daily_minute = '15'
  $cron_daily_hour = '0'

  # the alerting cronjob
  $cron_alerts_minute = '*'
  $cron_alerts_hour = '*'

  # check all the services
  $cron_check_services_minute = '*/5'
  $cron_check_services_hour = '*'

}
