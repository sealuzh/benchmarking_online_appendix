#
# Cookbook Name:: jm-acmeair-default
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


include_recipe 'cwb-jmeter::default'


#sudo apt-get update
include_recipe 'apt::default'

#install unzip
apt_package 'unzip' do
  action :install
end

#insert the driver.jar
cookbook_file '/usr/share/jmeter/lib/ext/acmeair-jmeter-1.1.0-SNAPSHOT.jar' do
  source 'acmeair-jmeter-1.1.0-SNAPSHOT.jar'
  mode '0644'
  action :create
end

#insert the json-mapper.jar
cookbook_file '/usr/share/jmeter/lib/ext/json-simple-1.1.1.jar' do
  source 'json-simple-1.1.1.jar'
  mode '0644'
  action :create
end

# currently not used - this task is currently done by the cwb-jmeter cookbook but should be changed
#cookbook_file '/usr/share/jmeter/bin/Airports.csv' do
#  source 'Airports.csv'
#  mode '0644'
#  action :create
#end

#cookbook_file '/usr/share/jmeter/bin/Airports2.csv' do
#  source 'Airports2.csv'
#  mode '0644'
#  action :create
#end

#update the testplan.jmx
template '/usr/share/jmeter/bin/AcmeAir.jmx' do
  source 'AcmeAir.jmx.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables({
    :target_host_port => node[:acmeairdefault][:testplan][:target_host][:port],  
    :target_host_name => node[:acmeairdefault][:testplan][:target_host][:name],
    :threadgroup_num_threads => node[:acmeairdefault][:testplan][:threadgroup][:num_threads],
    :threadgroup_ramp_up_time => node[:acmeairdefault][:testplan][:threadgroup][:ramp_up_time],
    :threadgroup_duration => node[:acmeairdefault][:testplan][:threadgroup][:duration],
    :threadgroup_delay => node[:acmeairdefault][:testplan][:threadgroup][:delay],
    :max_user_id_in_db => (node[:acmeairdefault][:testplan][:user_in_db]-1),
    :connection_timeout => node[:acmeairdefault][:testplan][:connection_timeout],
    :response_timeout => node[:acmeairdefault][:testplan][:response_timeout]
  })
end