# == Class: librenms::install
#
# This installs librenms via git checkout
#
# === Authors
#
# Andre Timmermann librenms@darktim.de
#
# === Copyright
#
# Copyright (C) 2016 Andre Timmermann
#
class librenms::install (
  $install_dir = hiera('librenms::params::install_dir' , $librenms::install_dir),
  $git_source = hiera('librenms::params::git_source' , $librenms::install::git_source),
  $librenms_user = hiera('librenms::params::librenms_user' , $librenms::install::librenms_user),
) inherits librenms::params {

  ensure_packages ('git')

  file {
    $install_dir:
      ensure => directory,
      owner  => $librenms_user,
      group  => $librenms_group,
      mode   => '0755';
    } ->
    vcsrepo {
      $install_dir:
        ensure   => present,
        provider => git,
        user     => $librenms_user,
        source   => $git_source,
        } ->
        file {
          [ "${install_dir}/rrd", "${install_dir}/logs" ]:
            ensure  => directory,
            owner   => $librenms_user,
            group   => 'www-data',
            mode    => '0775',
            require => Vcsrepo[$install_dir];
        }

}
