#
# Cookbook Name:: zookeeper
# Recipe:: devices 
#
# Copyright 2014, Zooniverse
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

execute "mkfs" do
  command "mkfs -t ext4 #{node['zookeeper']['data_device']}"
  not_if "grep -qs #{node['zookeeper']['data_dir']} /proc/mounts"
end

mount node['zookeeper']['data_dir'] do
  device node['zookeeper']['data_device']
  fstype "ext4"
  action [:mount, :enable]
end

execute "mkfs" do
  command "mkfs -t ext4 #{node['zookeeper']['data_log_device']}"
  not_if "grep -qs #{node['zookeeper']['data_log_dir']} /proc/mounts"
end

mount node['zookeeper']['data_log_dir'] do
  device node['zookeeper']['data_log_device']
  fstype "ext4"
  action [:mount, :enable]
end

[node['zookeeper']['data_log_dir'], node['zookeeper']['data_dir']].each do |dir|
  directory dir do
    owner node['zookeeper']['user']
    group node['zookeeper']['group']
  end
end
