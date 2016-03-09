# == Class: librenms::cron
#
# Install the cronjobs for LibreNMS.
#
# === Parameters
#
# Please refer to params.pp for all parameters used in this module.
#
# The cronjobs are taken from the file librenms.nonroot.cron inside of the checkout
#
# === Authors
#
# Andre Timmermann librenms@darktim.de
#
# === Copyright
#
# Copyright (C) 2016 Andre Timmermann
#
class librenms::cron (
  $librenms_user = hiera('librenms::params::librenms_user' , $librenms::cron::librenms_user),
  $install_dir = hiera('librenms::params::install_dir' , $librenms::cron::install_dir),
  $poller_threads = hiera('librenms::params::poller_threads' , $librenms::poller_threads),
  $cron_poller_wrapper_minute = hiera('librenms::params::cron_poller_wrapper_minute' , $librenms::cron::cron_poller_wrapper_minute),
  $cron_poller_wrapper_hour = hiera('librenms::params::cron_poller_wrapper_hour' , $librenms::cron::cron_poller_wrapper_hour),
  $cron_discover_new_minute = hiera('librenms::params::cron_discover_new_minute' , $librenms::cron::cron_discover_new_minute),
  $cron_discover_new_hour = hiera('librenms::params::cron_discover_new_hour' , $librenms::cron::cron_discover_new_hour),
  $cron_discover_all_minute = hiera('librenms::params::cron_discover_all_minute' , $librenms::cron::cron_discover_all_minute),
  $cron_discover_all_hour = hiera('librenms::params::cron_discover_all_hour' , $librenms::cron::cron_discover_all_hour),
  $cron_daily_minute = hiera('librenms::params::cron_daily_minute' , $librenms::cron::cron_daily_minute),
  $cron_daily_hour = hiera('librenms::params::cron_daily_hour' , $librenms::cron::cron_daily_hour),
  $cron_alerts_minute = hiera('librenms::params::cron_alerts_minute' , $librenms::cron::cron_alerts_minute),
  $cron_alerts_hour = hiera('librenms::params::cron_alerts_hour' , $librenms::cron::cron_alerts_hour),
  $cron_check_services_minute = hiera('librenms::params::cron_check_services_minute' , $librenms::cron::cron_check_services_minute),
  $cron_check_services_hour = hiera('librenms::params::cron_check_services_hour' , $librenms::cron::cron_check_services_hour),
) inherits librenms::params {

  cron {
    'librenms_poller_wrapper':
      command  => "${install_dir}/cronic ${install_dir}/poller-wrapper.py ${poller_threads} > /dev/null 2>&1",
      user     => $librenms_user,
      hour     => $cron_poller_wrapper_hour,
      minute   => $cron_poller_wrapper_minute;
    'librenms_discover_new':
      command  => "${install_dir}/discovery.php -h new > /dev/null 2>&1",
      user     => $librenms_user,
      hour     => $cron_discover_new_hour,
      minute   => $cron_discover_new_minute;
    'librenms_discovery_all':
      command  => "${install_dir}/discovery.php -h all > /dev/null 2>&1",
      user     => $librenms_user,
      hour     => $cron_discover_all_hour,
      minute   => $cron_discover_all_minute;
    'librenms_daily':
      command  => "${install_dir}/daily.sh > /dev/null 2>&1",
      user     => $librenms_user,
      hour     => $cron_daily_hour,
      minute   => $cron_daily_minute;
    'librenms_alerts':
      command  => "${install_dir}/alerts.php > /dev/null 2>&1",
      user     => $librenms_user,
      hour     => $cron_alerts_hour,
      minute   => $cron_alerts_minute;
    'librenms_check_services':
      command  => "${install_dir}/check_services.php > /dev/null 2>&1",
      user     => $librenms_user,
      hour     => $cron_check_services_hour,
      minute   => $cron_check_services_minute;
  }
}
