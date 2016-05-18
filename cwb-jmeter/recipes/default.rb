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

#install java
include_recipe 'java::default'

cookbook_file '/tmp/apache-jmeter-2.13.tgz' do
  source 'apache-jmeter-2.13.tgz'
  mode '0644'
  action :create
end

jmeter_root = node['cwbjmeter']['config']['jmeter_root']

directory jmeter_root do
  owner node[:cwbjmeter][:config][:ssh_username]
  group node[:cwbjmeter][:config][:ssh_username]
  recursive true
end

execute 'extract_jmeter_tgz' do
  command '  tar -xvf /tmp/apache-jmeter-2.13.tgz --strip-components=1'
  cwd jmeter_root
  not_if { File.directory?("#{jmeter_root}/bin") }
end

cookbook_file "#{jmeter_root}/bin/jmeter.properties" do
  source 'jmeter.properties'
  mode '0644'
  action :create
end


template "#{jmeter_root}/bin/user.properties" do
  source 'user.properties.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables({
     :remotes => node[:cwbjmeter][:config][:remotes],
     :sample_variables => node[:cwbjmeter][:config][:user_properties][:sample_variables]
  })
end

execute 'update_permissions_jm_bin_folder' do
  command "sudo chown #{node[:cwbjmeter][:config][:ssh_username]} bin/"
  cwd jmeter_root
end

execute 'update_permissions_jm_bin_files' do
  command "sudo chown #{node[:cwbjmeter][:config][:ssh_username]} *"
  cwd "#{jmeter_root}/bin/"
end

execute 'update_permissions_jm_jmeter_jmeter_server' do
  command "sudo chmod 0744 jmeter jmeter-server"
  cwd "#{jmeter_root}/bin/"
end

execute 'add_jmeter_to_registry' do
  command "ln -s #{jmeter_root}/bin/jmeter"
  cwd '/usr/local/bin/'
  not_if {::File.exists?('/usr/local/bin/jmeter') }
end

execute 'add_jmeter_server_to_registry' do
  command "ln -s #{jmeter_root}/bin/jmeter-server"
  cwd '/usr/local/bin/'
  not_if {::File.exists?('/usr/local/bin/jmeter-server') }
end

execute 'run_jmeter_as_slave' do
  command 'sudo nohup jmeter-server &'
  cwd "#{jmeter_root}/bin/"
  only_if { node[:cwbjmeter][:config][:slave] == true}
end
