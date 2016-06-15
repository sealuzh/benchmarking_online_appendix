#
# Cookbook Name:: jm-fileserver-readonly
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
    :target_host_port => node[:fileserverreadonly][:testplan][:target_host][:port],  
    :target_host_name => node[:fileserverreadonly][:testplan][:target_host][:name],
    :threadgroup_num_threads => node[:fileserverreadonly][:testplan][:threadgroup][:num_threads],
    :threadgroup_ramp_up_time => node[:fileserverreadonly][:testplan][:threadgroup][:ramp_up_time],
    :threadgroup_duration => node[:fileserverreadonly][:testplan][:threadgroup][:duration],
    :threadgroup_delay => node[:fileserverreadonly][:testplan][:threadgroup][:delay],
    :connection_timeout => node[:fileserverreadonly][:testplan][:connection_timeout],
    :response_timeout => node[:fileserverreadonly][:testplan][:response_timeout]
  })
end