#!/usr/bin/env ruby

Vagrant.configure('2') do |config|
  config.vm.hostname = 'zookeeper'

  config.vm.box = "opscode_ubuntu-13.10"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-13.10_chef-provisionerless.box"

  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest

  config.vm.network :private_network, ip: "33.33.33.10"

  config.vm.provision :chef_solo do |chef|
    chef.run_list = [
      'recipe[zookeeper::zookeeper]'
    ]
  end
end
