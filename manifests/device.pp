# == Class: librenms::device
#
# This class is used to export an Exec resource that adds this node to librenms.
#
# The idea is taken from https://github.com/Puppet-Finland/librenms
#
# Note that this class makes quite a few assumptions regarding snmpv3 to
# simplify the code:
#
# 1. Both authentication and encryption are used with snmpv3
# 2. SHA is used for authentication
# 3. AES is used for encryption
# 4. Both authentication and encryption are required
# 5. The snmp daemon is listening on the default port
#
# I suggest using hiera to set default parameters which then can be overridden
# on a per node base.
#
# == Parameters
#
# [*manage*]
#   Whether to add this node to LibreNMS. Valid values are true (default) and
#   false. You probably want to set this to false if you're including this class
#   on test nodes.
# [*install_dir*]
#   The directory into which LibreNMS is installed on the server side. Defaults
#   to '/opt/librenms'.
# [*community*]
#   The community string to use with SNMPv2(c). Leave empty (default) to
#   disable snmpv2.
# [*user*]
#   Snmpv3 username. Leave empty (default) to not use snmpv3.
# [*pass*]
#   Snmpv3 user password. Leave empty (default) to not use snmpv3.
# [*proto*]
#   Snmp protocol version. Valid values are 'v2c' and 'v3' (default). This
#   parameter is here primarily to reduce the conditional logic in this class.
# [*nodename*]
#   It may be needed to change the hostname of the node seen by librenms. For example
#   if you have a device with a random hostname in a cloud. This defaukts to the fqdn.
#
class librenms::device
(
  $manage = true,
  $install_dir = hiera('librenms::params::install_dir' , $librenms::params::install_dir),
  $mysql_db = hiera('librenms::params::mysql_db' , $librenms::params::mysql_db),
  $community = undef,
  $user = undef,
  $pass = undef,
  $proto = 'v3',
  $nodename = $::fqdn
) inherits librenms::params {
  validate_bool($manage)

  if $manage {

    $basecmd = "${install_dir}/addhost.php ${nodename}"

    case $proto {
      'v2c':    { $params = "${community} ${proto}" }
      'v3':     { $params = "ap ${proto} ${user} ${pass} ${pass} sha aes" }
      default: { fail("Invalid value ${proto} for parameter \$proto") }
    }

    $fullcmd = "${basecmd} ${params}"

    # Add the node if it does not already exist in LibreNMS database. The grep
    # is needed to produce a meaningful return value (0 or 1).
    @@exec { "Add ${nodename} to librenms":
      command => $fullcmd,
      path    => [ $install_dir, '/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin', 'usr/local/sbin' ],
      unless  => ["mysql --defaults-extra-file=/root/.my.cnf -e \"SELECT hostname FROM ${mysql_db}.devices WHERE hostname = \'${nodename}\'\"|grep ${nodename}"],
      user    => 'root',
      tag     => 'librenms-add_device',
    }
  }
}
