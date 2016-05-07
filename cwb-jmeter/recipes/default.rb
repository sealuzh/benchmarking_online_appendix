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

#install git
apt_package 'git' do
  action :install
end

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

#download the src files for the jmeter-test
git '/acmeair-driver' do
  repository 'https://github.com/acmeair/acmeair-driver.git'
  revision 'master'
  action :sync
end

#build the jmeter-test jar
execute 'build_driver' do
  command './gradlew build'
  cwd '/acmeair-driver'
end

#copy the jmeter-test.jar to jmeter install folder
execute 'copy_loader' do
  command 'cp /acmeair-driver/acmeair-jmeter/build/libs/acmeair-jmeter-*-SNAPSHOT.jar  /usr/share/jmeter/lib/ext/'
  cwd '/'
  not_if {::File.exists?('/apache-jmeter-2.13/lib/ext/acmeair-jmeter-*-SNAPSHOT.jar') }
end

#download an additional json mapper
execute 'download_json_simple' do
  command 'wget http://json-simple.googlecode.com/files/json-simple-1.1.1.jar'
  cwd '/'
  not_if {::File.exists?('/json-simple-1.1.1.jar') }
end

#copy the json mapper to jmeter install folder
execute 'copy_json_simple' do
  command 'cp /json-simple-1.1.1.jar  /usr/share/jmeter/lib/ext/'
  cwd '/'
  not_if {::File.exists?('/apache-jmeter-2.13/lib/ext/json-simple-1.1.1.jar') }
end

#template '/usr/share/jmeter/bin/hosts.csv' do
#  source 'hosts.csv.erb'
#  mode '0644'
#  owner 'root'
#  group 'root'
#  variables({
#     :hosts => node[:cwbjmeter][:config][:hosts]
#  })
#end

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

cookbook_file '/usr/share/jmeter/bin/user.properties' do
  source 'user.properties'
  mode '0644'
  action :create
end

template '/usr/share/jmeter/bin/jmeter.properties' do
  source 'jmeter.properties.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables({
     :remotes => node[:cwbjmeter][:config][:remotes]
  })
end


template '/usr/share/jmeter/bin/AcmeAir.jmx' do
  source 'AcmeAir.jmx.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables({
    :target_host_port => node[:cwbjmeter][:target_host][:port],  
    :target_host_name => node[:cwbjmeter][:target_host][:name],
    :threadgroup_num_threads => node[:cwbjmeter][:threadgroup][:num_threads],
    :threadgroup_ramp_up_time => node[:cwbjmeter][:threadgroup][:ramp_up_time],
    :threadgroup_duration => node[:cwbjmeter][:threadgroup][:duration],
    :threadgroup_delay => node[:cwbjmeter][:threadgroup][:delay]
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
  not_if {::File.exists?('/usr/local/bin/jmeter') }
end

execute 'run_jmeter_as_slave' do
  command 'sudo nohup jmeter-server &'
  cwd '/usr/share/jmeter/bin/'
  only_if { node[:cwbjmeter][:config][:slave] == true}
end
