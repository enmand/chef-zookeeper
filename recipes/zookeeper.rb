#
# Cookbook Name:: zookeeper
# Recipe:: zookeeper
#
# Copyright 2013, Simple Finance Technology Corp.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "java::default"

node.override['build_essential']['compiletime'] = true
include_recipe "build-essential"

chef_gem "zookeeper"
chef_gem "json"

group node['zookeeper']['group'] do
  action :create
end

user node['zookeeper']['user'] do
  gid node['zookeeper']['group']
end

zk_basename = "zookeeper-#{node['zookeeper']['version']}"

remote_file ::File.join(Chef::Config[:file_cache_path], "#{zk_basename}.tar.gz") do
  owner "root"
  mode "0644"
  source node['zookeeper']['mirror']
  checksum node['zookeeper']['checksum']
  action :create
end

[
  node['zookeeper']['data_dir'],
  node['zookeeper']['install_dir'], 
  node['zookeeper']['data_log_dir']
].each do |dir|
  directory dir  do
    owner node['zookeeper']['user']
    group node['zookeeper']['group']
    mode "0755"
  end
end

unless ::File.exists?(::File.join(node['zookeeper']['install_dir'], zk_basename))
  execute 'install zookeeper' do
    cwd Chef::Config[:file_cache_path]
    command "tar -C '#{node['zookeeper']['install_dir']}' -zxf '#{zk_basename}.tar.gz' && chown -R '#{node['zookeeper']['user']}:#{node['zookeeper']['group']}' #{node['zookeeper']['install_dir']}"
  end
end

template "#{node['zookeeper']['install_dir']}/zookeeper-#{node['zookeeper']['version']}/conf/zoo.cfg" do
  source "zoo.cfg.erb"
  owner node['zookeeper']['user']
  group node['zookeeper']['group']
  mode '0755'
  action :create
  variables({
    data_dir: node['zookeeper']['data_dir'],
    data_log_dir: node['zookeeper']['data_log_dir'],
    servers: node['zookeeper']['cluster']
  })
end

server_id = node['zookeeper']['cluster'].map{|s| s.split(".").first}.find_index(node['hostname'])

file "#{node['zookeeper']['data_dir']}/myid" do
  content server_id
  mode "0755"
  owner node['zookeeper']['user']
  group node['zookeeper']['group']
  action :create
end
        

template "/etc/init/zookeeper.conf" do 
  source "zookeeper.upstart.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

service "zookeeper" do
  provider Chef::Provider::Service::Upstart
  supports start: true, restart: true, status: true
  action [:enable, :start]
end
