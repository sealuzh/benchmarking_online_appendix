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

#install jmeter
apt_package 'jmeter' do
  action :install
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

#insert a config and other files needed for the test
#cookbook_file '/usr/share/jmeter/bin/hosts.csv' do
#  source 'hosts.csv'
#  mode '0777'
#  action :create
#end

template '/usr/share/jmeter/bin/hosts.csv' do
  source 'hosts.csv.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables({
     :hosts => node[:config][:hosts]
  })
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

#cookbook_file '/usr/share/jmeter/bin/jmeter.properties' do
#  source 'jmeter.properties'
#  mode '0777'
#  action :create
#end

template '/usr/share/jmeter/bin/jmeter.properties' do
  source 'jmeter.properties.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables({
     :remotes => node[:config][:remotes]
  })
end

cookbook_file '/usr/share/jmeter/bin/user.properties' do
  source 'user.properties'
  mode '0644'
  action :create
end

cookbook_file '/usr/share/jmeter/bin/AcmeAir.jmx' do
  source 'AcmeAir.jmx'
  mode '0644'
  action :create
end

execute 'update_permissions_jm_bin_folder' do
  command 'sudo chown ubuntu bin/'
  cwd '/usr/share/jmeter/'
end

execute 'update_permissions_jm_bin_files' do
  command 'sudo chown ubuntu *'
  cwd '/usr/share/jmeter/bin/'
end

execute 'run_jmeter_as_slave' do
  command 'sudo jmeter-server'
  cwd '/usr/share/jmeter/bin/'
  only_if { node[:config][:jmeter][:slave] == true}
end
