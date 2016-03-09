# == Class: librenms
#
# Installs LibreNMS (http://www.librenms.org)
#
# === Parameters
#
# Please refer to params.pp for all parameters used in this module.
#
# === Examples
#
# include librenms
#
# You HAVE to provide a password for the mysql database (librenms::mysql).
# If you do not want to use the librenms::mysql, please disable it ;)
#
# Please refer to the readme for setting up the webserver.
#
# === Authors
#
# Andre Timmermann librenms@darktim.de
#
# === Copyright
#
# Copyright (C) 2016 Andre Timmermann
#
class librenms (
  $librenms_user = hiera('librenms::params::librenms_user' , $librenms::librenms_user),
  $librenms_group = hiera('librenms::params::librenms_group' , $librenms::librenms_group),
  $install_dir = hiera('librenms::params::install_dir' , $librenms::install_dir),
  $configure_mysql = hiera('librenms::params::configure_mysql' , $librenms::configure_mysql),
  $configure_cron = hiera('librenms::params::configure_cron' , $librenms::configure_cron),
  $collector = hiera('librenms::params::collector' , $librenms::collector),
) inherits librenms::params {

  group {
    $librenms_group:
      ensure => present,
      system => true;
  }
  user {
    $librenms_user:
      ensure     => present,
      comment    => 'LibreNMS system user',
      managehome => false,
      system     => true,
      gid        => $librenms_group,
      home       => $install_dir,
      require    => Group[$librenms_group];
  }

  # installs librenms via git clone
  include librenms::install

  # installs/configures mysql
  if $configure_mysql {
    include librenms::mysql
  }

  # configures cronjobs
  if $configure_cron {
    include librenms::cron
  }

  # adds the collector of devices
  if $collector {
    include librenms::add_device
  }

}
