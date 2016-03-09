# Exec['/usr/bin/apt-get update || true'] -> Package <| |>
# Exec {
#   path => '/usr/bin:/usr/sbin:/bin'
# }

class { '::mysql::server':
  root_password             => 'strongpassword',
  } ->
  class { 'librenms': }
