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



fileserver_dir = '/usr/share/fileserver'

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

#TODO: make arguments configurable and don't forgett to update the template for autorun command in templates folder!
execute 'run_fileserver' do
  command "sudo nohup java -Xms#{node[:fileserver][:config][:heap_size_xms]} -Xmx#{node[:fileserver][:config][:heap_size_xmx]} -jar #{fileserver_filename} &"
  cwd "#{fileserver_dir}"
end

template '/etc/rc.local' do
  source 'rc.local.erb'
  variables({
    :fileserver_dir => fileserver_dir,
    :fileserver_filename => fileserver_filename,
    :heap_size_xms => node[:fileserver][:config][:heap_size_xms],
    :heap_size_xmx => node[:fileserver][:config][:heap_size_xmx]
  })
end