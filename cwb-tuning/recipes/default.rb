#
# Cookbook Name:: cwb-tuning
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

execute 'increase_open_files' do
  command 'sudo echo "fs.file-max = 65536" >> /etc/sysctl.conf'
end

execute 'increase_ulimit' do
  command 'sudo echo "* soft nofile 65536" >> /etc/security/limits.conf && sudo echo "* hard nofile 65536" >> /etc/security/limits.conf'
end
