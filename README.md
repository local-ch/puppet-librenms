# librenms

#### Table of Contents

  1. [Module Description - What the module does and why it is useful](#module-description)
  2. [Setup - The basics of getting started with librenms](#setup)
  * [Beginning with librenms](#beginning-with-librenms)
  3. [Usage - Configuration options and additional functionality](#usage)
  * [Customize configuration](#customize-configuration)
  * [Webserver Configuration - a proposal](#webserver-configuration)
  4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
  5. [Limitations - OS compatibility, etc.](#limitations)

## Module Description

The librenms module installs, configures, and manages the Libre Network Monitoring System.

This module manages both the installation and some parts of the configuration of librenms, such as cronjobs and automatically collecting puppet managed systems.

## Setup

### Beginning with librenms

To install librenms with the default options (you MUST provide a MySQL password for the database):

```puppet
include librenms
```
```hiera
---
librenms::mysql::mysql_pass: 'superstrongpass'
```

## Usage

Puppet collects exported ressources from librenms::device to add devices to its database. So add this to all servers:

```puppet
class { '::librenms:device':
  proto     => 'v2c',
  community => 'public',
  nodename  => 'bla.excample.com';
}
```

Of course, you can use hiera to set these values:

```puppet
include ::librenms:device
```

```hiera
---
librenms::device::proto: 'v2c'
librenms::device::proto:community: 'public'
librenms::device::proto::nodename: 'bla.example.com'
```

### Customize configuration

You can change some values of the setup:

```puppet
class { '::librenms':
  librenms_user   => 'otheruser',
  librenms_group  => 'othergroup',
  install_dir     => '/some/where/else',
  configure_mysql => false,
  configure_cron  => false,
  collector       => false;
}
```
You can use hiera as well:

```puppet
include ::librenms
```
```hiera
---
librenms::librenms_user: 'otheruser'
librenms::librenms_group: 'othergroup'
librenms::install_dir: '/some/where/else'
librenms::configure_mysql: false
librenms::configure_cron: false
librenms::collector: false
```

### Webserver configuration

This is a complete proposal for a librenms server:

#### Profile
Your profile can look like this. You still have to care about the firewall and the deployment of the SSL certificate files.

```puppet
class profile::librenms {

  # make the webserveruser aware to puppet, so that it can be added to the ssl-cert group
  User<| title == www-data |> {
    groups  +> ['ssl-cert'],
    require => Package[ssl-cert]
  }

  # install some dependency packages (uses puppetlabs/stdlib)
  ensure_packages(['php5-mysql', 'php5-mcrypt', 'php5-gd', 'php5-snmp', 'php-pear', 'python-mysqldb', 'php-net-ipv4', 'php-net-ipv6', 'rrdtool'])

  # install librenms, config data is taken from hiera
  include ::librenms

  # install apache, config data is taken from hiera (uses puppetlabs/apache)
  include ::apache

  # enable apache modules
  $apache_modules = ['rewrite', 'php5']
  apache::mod{ $apache_modules: }

  # now fetch the vhost-config via hiera
  $vhosts = hiera_hash('vhosts')
  create_resources(apache::vhost, $vhosts)

  # install mysql, config data is taken from from hiera
  include ::mysql::server

}
```
### hiera config
```hiera
---

# apache config
apche::serveradmin: 'admin@example.com'
apache::default_vhost: false
apache::mpm_module: 'prefork'

# apache vhosts
vhosts:
    'librenms.example.com_80':
      port: 80
      servername: 'librenms.example.com'
      docroot: '/opt/librenms/html'
      manage_docroot: false
      redirect_source: '/'
      redirect_status: 'permanent'
      redirect_dest: 'https://librenms.example.com/'
    'librenms.example.com_443':
      port: '443'
      servername: 'librenms.example.com'
      docroot: '/opt/librenms/html'
      manage_docroot: false
      ssl: true
      ssl_cert: '/etc/ssl/certs/star.example.com.crt'
      ssl_key: '/etc/ssl/private/star.examplee.com.key'
      ssl_ca: '/etc/ssl/certs/CA_ROOT.example.com.crt'
      override: 'all'
      custom_fragment: 'AddType application/x-httpd-php .php'

# mysql server
mysql::server:root_password: 'SecureMysqlRootpassword'
mysql::server::override_options:
  mysqld:
    innodb_file_per_table: '1'

# librenms DB password
librenms::mysql::mysql_pass: 'SecurePasswordNumber9'

```


## Reference

### Classes

#### Public classes

* `librenms`: Installs and configures librenms
* `librenms::device`: Adds the ressource exporter

#### Private classes
* `add_device`: Collector for the exported ressources
* `librenms::cron`: Installs cornjobs
* `librenms::install`: Adds users and checks out Git repo
* `librenms::mysql`: Configure the MySQL database
* `librenms::params`: Parameters for the install

### Parameters

* the install directory for the git checkout
  * $install_dir = '/opt/librenms'

* the git repository to be used.
  * $git_source = 'https://github.com/librenms/librenms.git'

* if you want to use librenms::mysql to set up the database
  * $configure_mysql = true

* if you want to use librenms::cron to set up the cronjobs
  * $configure_cron = true

* if you want to use librenms::add_device collector so that all hosts with class librenms::device will be added to LibreNMS
  * $collector = true

* user and group to be created/used by LibreNMS
  * $librenms_user = 'librenms'
  * $librenms_group = 'librenms'

* these are used by librenms::mysql
  * $mysql_db = 'librenms'
  * $mysql_user = 'librenms'
  * $mysql_pass = ''

* these are used by librenms::cron
* The values are taken from the file librenms.nonroot.cron inside of the checkout
* By default, the cron job runs poller-wrapper.py with 16 threads. The current recommendation is to use 4 threads per core as a rule of thumb.
  * $poller_threads = '16'

* when the poller-wrapper should run
  * $cron_poller_wrapper_minute = '*/5'
  * $cron_poller_wrapper_hour = '*'

* discover all new devices
  * $cron_discover_new_minute = '*/5'
  * $cron_discover_new_hour = '*'

* (re)-discover ALL devices
  * $cron_discover_all_minute = '33'
  * $cron_discover_all_hour = '*/6'

* the daily cronjobs
  * $cron_daily_minute = '15'
  * $cron_daily_hour = '0'

* the alerting cronjob
  * $cron_alerts_minute = '*'
  * $cron_alerts_hour = '*'

* check all the services
  * $cron_check_services_minute = '*/5'
  * $cron_check_services_hour = '*'

## Limitations

The module is tested with Debian Jessie. It is not guaranteed that it works with other systems. Please test and send pull requests.

The module depends on the following modules.

### puppetlabs/stdlib
version_requirement: ">= 3.2.0"

### puppetlabs/vcsrepo
version_requirement: ">=  1.3.2"

### puppetlabs/mysql
version_requirement: ">=  3.6.2"

### hiera

