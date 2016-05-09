#
# Cookbook Name:: fileserver
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'apt::default'
include_recipe 'java::default'


include_recipe 'firewall::default'
ports = node[:firewall][:ports]
firewall_rule "open ports #{ports}" do
  port ports
end



fileserver_dir = '/usr/local/share/fileserver'

directory fileserver_dir do
  owner node[:fileserver][:config][:ssh_username]
  group node[:fileserver][:config][:ssh_username]
  recursive true
end

fileserver_filename = 'fileserver-0.1.0.jar'
cookbook_file "#{fileserver_dir}/#{fileserver_filename}" do
  source "#{fileserver_filename}"
  mode '0777'
  action :create
end

execute 'run_fileserver' do
  command "java -jar #{fileserver_filename}"
  cwd "#{fileserver_dir}"
end
