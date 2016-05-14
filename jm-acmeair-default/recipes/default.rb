#
# Cookbook Name:: jm-acmeair-default
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


include_recipe 'cwb-jmeter::default'

jmeter_root = node[:cwbjmeter][:config][:jmeter_root]

#update the testplan.jmx
template "#{jmeter_root}/bin/AcmeAir.jmx" do
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