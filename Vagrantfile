# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.4.0"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # For 'magnum-vagrant' we acquire vagrant boxes from: http://puppet-vagrant-boxes.puppetlabs.com/
  config.vm.box = "puppetlabs/debian-8.2-64-puppet"
  config.vm.hostname = "foo-bar.ch"
  config.vm.provision :shell, :path => "./.vagrant_puppet/init.sh"
  config.vm.synced_folder "spec/fixtures/hiera/data", "/tmp/data"
  config.vm.provision :puppet do |puppet|
    puppet.environment_path     = "puppet/environments"
    puppet.environment          = "development"
    puppet.manifests_path       = "puppet/environments/development/manifests"
    puppet.module_path = ["./","~/localch/vcs/environments/production/modules"]
    puppet.manifest_file  = "init.pp"
    puppet.hiera_config_path = "hiera.yaml"
    puppet.working_directory = "./"
    puppet.options = "--verbose"
  end

end
