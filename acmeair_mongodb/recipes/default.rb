# Cookbook Name:: acmeair_mongodb
# Recipe:: default

#install mongodb in older version
include_recipe "mongodb::10gen_repo"
include_recipe "mongodb::default"

template '/etc/mongod.conf' do
  source 'mongod.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables({
     :bind_ip => node[:mongodb][:config][:bind_ip]
  })
end

template '/load_db_user.js' do
  source 'load_db_user.js.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables({
    :db_name => node[:acmeairdb][:name],
    :db_user_name => node[:acmeairdb][:user][:name],
    :db_user_password => node[:acmeairdb][:user][:password]
  })
end

directory "/dump" do
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

cookbook_file '/acmeair_mongodb_dump.tar.gz' do
  mode '0644'
  not_if {::File.exists?('/acmeair_mongodb_dump.tar.gz') }
end

execute 'untar_dump' do
  command 'tar -xvzf acmeair_mongodb_dump.tar.gz --strip-components 1 -C /dump'
  not_if { ::File.directory?('/dump/admin') }
  notifies :restart,  'service[mongod]', :immediately
end

#restart the service
service 'mongod' do
  supports :status => true, :start => true, :restart => true, :stop => true
  action :nothing
  notifies :run,  'execute[looad_db_from_dump]', :immediately
end

execute 'looad_db_from_dump' do
  command "mongorestore --port #{node[:mongodb][:config][:port]} /dump"
  action :nothing
  notifies :run,  'execute[looad_db_user_to_db]', :immediately
  retries 90
end

execute 'looad_db_user_to_db' do
  action :nothing
  command "mongo localhost:#{node[:mongodb][:config][:port]}/#{node[:acmeairdb][:name]} /load_db_user.js"
end