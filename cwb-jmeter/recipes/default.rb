#
# Cookbook Name:: cwb-jmeter
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

#disable the firewall
include_recipe 'firewall::default'
firewall 'default' do
  action :disable
end

#sudo apt-get update
include_recipe 'apt::default'


#install java
include_recipe 'java::default'

#apt-get does not provide the latest version if jmeter
cookbook_file '/usr/share/jmeter.zip' do
  source 'jmeter.zip'
  mode '0644'
  action :create
end

#install unzip
apt_package 'unzip' do
  action :install
end

#unzip jmeter
execute 'unzip_jmeter' do
  command 'unzip jmeter.zip'
  cwd '/usr/share/'
  not_if {::File.directory?('/usr/share/jmeter') }
end

cookbook_file '/usr/share/jmeter/bin/Airports.csv' do
  source 'Airports.csv'
  mode '0644'
  action :create
end

cookbook_file '/usr/share/jmeter/bin/Airports2.csv' do
  source 'Airports2.csv'
  mode '0644'
  action :create
end

cookbook_file '/usr/share/jmeter/bin/jmeter.properties' do
  source 'jmeter.properties'
  mode '0644'
  action :create
end


template '/usr/share/jmeter/bin/user.properties' do
  source 'user.properties.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables({
     :remotes => node[:cwbjmeter][:config][:remotes]
  })
end

execute 'update_permissions_jm_bin_folder' do
  command "sudo chown #{node[:cwbjmeter][:config][:ssh_username]} bin/"
  cwd '/usr/share/jmeter/'
end

execute 'update_permissions_jm_bin_files' do
  command "sudo chown #{node[:cwbjmeter][:config][:ssh_username]} *"
  cwd '/usr/share/jmeter/bin/'
end

execute 'update_permissions_jm_jmeter_jmeter_server' do
  command "sudo chmod 0744 jmeter jmeter-server"
  cwd '/usr/share/jmeter/bin/'
end

execute 'add_jmeter_to_registry' do
  command "ln -s /usr/share/jmeter/bin/jmeter"
  cwd '/usr/local/bin/'
  not_if {::File.exists?('/usr/local/bin/jmeter') }
end

execute 'add_jmeter_server_to_registry' do
  command "ln -s /usr/share/jmeter/bin/jmeter-server"
  cwd '/usr/local/bin/'
  not_if {::File.exists?('/usr/local/bin/jmeter-server') }
end

execute 'run_jmeter_as_slave' do
  command 'sudo nohup jmeter-server &'
  cwd '/usr/share/jmeter/bin/'
  only_if { node[:cwbjmeter][:config][:slave] == true}
end
