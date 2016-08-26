# Cookbook Name:: acmeair_wlp_morphia
# Recipe:: default


#configure firewall
include_recipe 'firewall::default'
ports = node.default['morphia_server']['open_ports']
firewall_rule "open ports #{ports}" do
  port ports
end

#apt-get update
include_recipe 'apt::default'
#install java
include_recipe 'java::default'

#install wlp
include_recipe 'wlp::default'

#download the mongo-java-driver
cookbook_file '/mongo-java-driver-2.12.2.jar' do
  mode '0644'
  not_if {::File.exists?('/mongo-java-driver-2.12.2.jar') }
end

#make a folder
execute 'mkdir_mongo-java-driver' do
  command 'mkdir ./mongodb'
  cwd '/opt/was/liberty/wlp/usr/shared/resources'
  not_if { ::File.directory?('/opt/was/liberty/wlp/usr/shared/resources/mongodb') }
end

#install i.e move the driver to the folder
execute 'move_mongo-java-driver' do
  command 'mv mongo-java-driver-2.12.2.jar /opt/was/liberty/wlp/usr/shared/resources/mongodb'
  cwd '/'
  not_if {::File.exists?('/opt/was/liberty/wlp/usr/shared/resources/mongodb/mongo-java-driver-2.12.2.jar') }
end

#install mongodb feature to WLP
wlp_install_feature "mongodb" do
  location "mongodb-2.0"
  accept_license true
end

#create a new webserver-instance
wlp_server "server1" do
  action :create
end

cookbook_file '/acmeair-webapp-2.0.0-SNAPSHOT.war' do
  mode '0644'
  not_if {::File.exists?('/acmeair-webapp-2.0.0-SNAPSHOT.war') }
end


#copy to buildfiles to the WLP folder
execute 'copy_webapp' do
  command 'cp /acmeair-webapp-2.0.0-SNAPSHOT.war /opt/was/liberty/wlp/usr/servers/server1/apps/'
end

template '/opt/was/liberty/wlp/usr/servers/server1/server.xml' do
  source 'server.xml.erb'
  owner 'wlp'
  group 'wlpadmin'
  mode '0644'
  variables({
   :mongodb_ip => node[:mongodb][:ip],
   :mongodb_port => node[:mongodb][:port],
   :mongodb_name => node[:mongodb][:name]
  })
end

#install the mongodb in a older version
include_recipe "mongodb::10gen_repo"
include_recipe "mongodb::default"

#start the server
wlp_server "server1" do
  clean true
  action :start
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
  command 'tar -xvzf acmeair_mongodb_dump.tar.gz -C /dump'
  not_if { ::File.directory?('/dump/admin') }
end

execute 'looad_db_from_dump' do
  command "mongorestore --port #{node[:mongodb][:port]} /dump"
  not_if { ::File.directory?('/dump/admin') }
end

template '/load_db_user.js' do
  source 'load_db_user.js.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables({
    :db_name => node[:mongodb][:name]
  })
end

execute 'looad_db_user_to_db' do
  command "mongo localhost:#{node[:mongodb][:port]}/#{node[:mongodb][:name]} /load_db_user.js"
  not_if { ::File.directory?('/dump/admin') }
end