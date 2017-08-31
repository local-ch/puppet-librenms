# == Class: librenms::mysql
#
# Installs the mysql database for LibreNMS. It uses the puppetlabs/mysql module.
#
# === Parameters
#
# Please refer to params.pp for all parameters used in this module.
#
# Warning: you HAVE to define a password for the databse.
#
# === Authors
#
# Andre Timmermann librenms@darktim.de
#
# === Copyright
#
# Copyright (C) 2016 Andre Timmermann
#
class librenms::mysql (
  $mysql_db = hiera('librenms::params::mysql_db' , $librenms::params::mysql_db),
  $mysql_user = hiera('librenms::params::mysql_pass' , $librenms::params::mysql_user),
  $mysql_pass = hiera('librenms::params::mysql_user' , $librenms::params::mysql_pass),
) inherits librenms::params {

  # fail if db password is empty
  if $mysql_pass == '' {
    fail('mysql_pass may not be empty')
  }

  # deploy databases
  mysql::db {
    [$mysql_db]:
      user     => $mysql_user,
      password => $mysql_pass,
      host     => 'localhost',
      grant    => ['all'],
      charset  => 'utf8',
      collate  => 'utf8_unicode_ci',
      require  => Class['mysql::server'];
  }

}
