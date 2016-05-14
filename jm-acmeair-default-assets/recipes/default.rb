#
# Cookbook Name:: jm-acmeair-default-assets
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

jmeter_root_dir = node['acmeairdefaultassets']['jmeter']['root_dir']

#insert the driver.jar
cookbook_file "#{jmeter_root_dir}/lib/ext/acmeair-jmeter-1.1.0-SNAPSHOT.jar" do
  source 'acmeair-jmeter-1.1.0-SNAPSHOT.jar'
  mode '0644'
  action :create
end

#insert the json-mapper.jar
cookbook_file '#{jmeter_root_dir}/lib/ext/json-simple-1.1.1.jar' do
  source 'json-simple-1.1.1.jar'
  mode '0644'
  action :create
end

cookbook_file '#{jmeter_root_dir}/bin/Airports.csv' do
  source 'Airports.csv'
  mode '0644'
  action :create
end

cookbook_file '#{jmeter_root_dir}/bin/Airports2.csv' do
  source 'Airports2.csv'
  mode '0644'
  action :create
end