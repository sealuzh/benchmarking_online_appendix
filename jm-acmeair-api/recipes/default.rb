#
# Cookbook Name:: jm-acmeair-api
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


include_recipe 'cwb-jmeter::default'

jmeter_root = node[:cwbjmeter][:config][:jmeter_root]

#update the testplan.jmx
template "#{jmeter_root}/bin/jmeter_testplan.jmx" do
  source 'jmeter_testplan.jmx.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables({
    :target_host_port => node[:acmeairapi][:testplan][:target_host][:port],  
    :target_host_name => node[:acmeairapi][:testplan][:target_host][:name],
    :threadgroup_num_threads => node[:acmeairapi][:testplan][:threadgroup][:num_threads],
    :threadgroup_ramp_up_time => node[:acmeairapi][:testplan][:threadgroup][:ramp_up_time],
    :threadgroup_duration => node[:acmeairapi][:testplan][:threadgroup][:duration],
    :threadgroup_delay => node[:acmeairapi][:testplan][:threadgroup][:delay],
    :max_user_id_in_db => (node[:acmeairapi][:testplan][:user_in_db]-1),
    :connection_timeout => node[:acmeairapi][:testplan][:connection_timeout],
    :response_timeout => node[:acmeairapi][:testplan][:response_timeout]
  })
end