#
# Cookbook Name:: acmeair_mongodb
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

#install mongodb in older version
include_recipe "mongodb::10gen_repo"
include_recipe "mongodb::default"

template '/etc/mongod.conf' do
  source 'mongod.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables({
     :bind_ip => node[:conf][:mongod][:bind_ip]
  })
  notifies :run,  'execute[create_db_and_user]', :delayed
end

#create the db username and user password
execute 'create_db_and_user' do
 command 'mongo acmeair --eval \'db.createUser({user: "acmeairusr",pwd: "Login4Acme!",roles: [ { role: "readWrite", db: "acmeair" },{ role: "dbAdmin", db: "acmeair" }]})\''
 action :nothing
 returns [0,252]
 retries 90
 notifies :restart,  'service[mongod]', :immediate
end

#restart the service and then create the user
service 'mongod' do
  supports :status => true, :start => true, :restart => true, :stop => true
  action :nothing
end

