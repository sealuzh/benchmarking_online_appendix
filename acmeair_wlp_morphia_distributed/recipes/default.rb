#
# Cookbook Name:: acmeair_wlp_morphia_distributed
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


include_recipe 'firewall::default'

ports = node[:firewall][:ports]
firewall_rule "open ports #{ports}" do
  port ports
end

include_recipe 'apt::default'
include_recipe 'java::default'


apt_package 'git' do
  action :install
end

include_recipe 'wlp::default'

execute 'download_mongo-java-driver' do
  command 'wget https://oss.sonatype.org/content/repositories/releases/org/mongodb/mongo-java-driver/2.12.2/mongo-java-driver-2.12.2.jar'
  cwd '/'
  not_if {::File.exists?('/opt/was/liberty/wlp/usr/shared/resources/mongodb/mongo-java-driver-2.12.2.jar') }
end

#needs the mongo driver to installed in the application not the context but works 
#execute 'export_mongodb_VCAP' do
#  command 'export VCAP_SERVICES=\'{"mongo":[{"credentials":{"url":"mongodb://<user>:<pwd>@<host>:<port>/<dbname>"}}]}\''
#end

execute 'export_WLP_BIN' do
  command 'sudo echo "WLP_SERVER=/opt/was/liberty/wlp/bin" >> /etc/environment'
end

execute 'export_WLP_START' do
  command 'sudo echo "WLP_START=/opt/was/liberty/wlp/bin/server start server1" >> /etc/environment'
end

execute 'export_WLP_STOP' do
  command 'sudo echo "WLP_STOP=/opt/was/liberty/wlp/bin/server stop server1" >> /etc/environment'
end

execute 'mkdir_mongo-java-driver' do
  command 'mkdir ./mongodb'
  cwd '/opt/was/liberty/wlp/usr/shared/resources'
  not_if { ::File.directory?('/opt/was/liberty/wlp/usr/shared/resources/mongodb') }
end

execute 'move_mongo-java-driver' do
  command 'mv mongo-java-driver-2.12.2.jar /opt/was/liberty/wlp/usr/shared/resources/mongodb'
  cwd '/'
  not_if {::File.exists?('/opt/was/liberty/wlp/usr/shared/resources/mongodb/mongo-java-driver-2.12.2.jar') }
end

wlp_install_feature "mongodb" do
  location "mongodb-2.0"
  accept_license true
end

wlp_server "server1" do
  action :create
end

git '/acmeair-buildfiles' do
  repository 'https://github.com/crixx/acmeair-buildfiles.git'
  revision 'morphia-distributed'
  action :sync
end

execute 'copy_webapp' do
  command 'cp /acmeair-buildfiles/acmeair-webapp/build/libs/acmeair-webapp-2.0.0-SNAPSHOT.war /opt/was/liberty/wlp/usr/servers/server1/apps/'
end

template '/opt/was/liberty/wlp/usr/servers/server1/server.xml' do
	source 'server.xml.erb'
	owner 'wlp'
	group 'wlpadmin'
	mode '0644'
	variables({
	 :mongodb_ip => node[:mongodb][:ip],
	 :mongodb_port => node[:mongodb][:port],
	 :mongodb_name => node[:mongodb][:name],
	 :mongodb_user_name => node[:mongodb][:user][:name],
	 :mongodb_user_password => node[:mongodb][:user][:password],
   :http_port => node[:config][:webapp][:port][:http],
   :https_port => node[:config][:webapp][:port][:https]
	})
end

wlp_server "server1" do
  clean true
  action :start 
end

#load the database with some users
#execute 'load_users_to_db' do
#  command "curl 'http://localhost:#{node[:config][:webapp][:port]}/acmeair-webapp/rest/info/loader/load?numCustomers=#{node[:config][:webapp][:users_to_load]}'"
#  retries 60
#end

ruby_block 'load_users_to_db' do
  block do   
    require 'net/http'
    res = Net::HTTP.get_response(URI("http://localhost:#{node[:config][:webapp][:port][:http]}/acmeair-webapp/rest/info/loader/load?numCustomers=#{node[:config][:webapp][:users_to_load]}"))
    if  res.body.include? "Loaded flights and"
    else
      raise "An error has occured: #{res.code} #{res.message}"
    end
  end
  retries 60
end