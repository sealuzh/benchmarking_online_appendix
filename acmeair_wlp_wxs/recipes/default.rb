# Cookbook Name:: acmeair_wlp_wxs
# Recipe:: default

include_recipe 'firewall::default'

ports = node.default['wxs_server']['open_ports']
firewall_rule "open ports #{ports}" do
  port ports
end

execute 'add_host_entry' do
  command 'sudo echo "127.0.0.1 default-ubuntu-1404" >> /etc/hosts'
end

#add shorthand $WLP_DIR
execute 'export_WLP_DIR' do
  command 'sudo echo "WLP_DIR=/opt/was/liberty/wlp/" >> /etc/environment'
end

#add shorthand to start the server $WLP_START
execute 'export_WLP_START' do
  command 'sudo echo "WLP_START=/opt/was/liberty/wlp/bin/server start server1" >> /etc/environment'
end

#add shorthand to stop the server $WLP_STOP
execute 'export_WLP_STOP' do
  command 'sudo echo "WLP_STOP=/opt/was/liberty/wlp/bin/server stop server1" >> /etc/environment'
end

#install java 7 - version in attributes
include_recipe 'java::default'

#apt-get update
include_recipe 'apt::default'

#install unzip
apt_package 'unzip' do
  action :install
end

#install websphere liberty
include_recipe 'wlp::default'

#copy wxs-integration-profile from files 
cookbook_file '/opt/was/liberty/wxs-wlp_8.6.0.8.jar' do
  source 'wxs-wlp_8.6.0.8.jar'
  action :create
end

#install the profile
execute 'install_wxs_in_wlp' do
  command 'java -jar wxs-wlp_8.6.0.8.jar --acceptLicense /opt/was/liberty'
  cwd '/opt/was/liberty'
  not_if { ::File.directory?('/opt/was/liberty/wlp/wxs') }
end

#create a server
wlp_server "server1" do
  action :create
end

#copy build files folder
cookbook_file '/acmeair-buildfiles.zip' do
  source 'acmeair-buildfiles.zip'
  action :create
end

#unzip it
execute 'buildfiles_unzip' do
  command 'unzip acmeair-buildfiles.zip'
  cwd '/'
  not_if { ::File.directory?('/acmeair-buildfiles') }
end

#copy the webapp to the server
execute 'copy_webapp' do
  command 'cp /acmeair-buildfiles/acmeair-webapp/build/libs/acmeair-webapp-2.0.0-SNAPSHOT.war /opt/was/liberty/wlp/usr/servers/server1/dropins/'
end

#rename the webapp to ommit the version
execute 'rename_webapp' do
  command 'mv /opt/was/liberty/wlp/usr/servers/server1/dropins/acmeair-webapp-2.0.0-SNAPSHOT.war /opt/was/liberty/wlp/usr/servers/server1/dropins/acmeair-webapp.war'
end

#copy the database from the cookbook files folder
cookbook_file '/extremescaletrial8.6.0.8.zip' do
  source 'extremescaletrial8.6.0.8.zip'
  action :create
end

#unzip it
execute 'wxs_unzip' do
  command 'unzip extremescaletrial8.6.0.8.zip'
  cwd '/'
  not_if { ::File.directory?('/ObjectGrid') }
end

#move it to a better place
execute 'move_wxs' do
  command 'mv /ObjectGrid /opt/was/liberty/'
  not_if { ::File.directory?('/opt/was/liberty/ObjectGrid') }
end

#move the config files
execute 'copy_deployment_xml' do
  command 'cp /acmeair-buildfiles/acmeair-services-wxs/src/main/resources/deployment.xml /opt/was/liberty/ObjectGrid/gettingstarted/server/config/.'
end

execute 'copy_objectGrid_xml' do
  command 'cp /acmeair-buildfiles/acmeair-services-wxs/src/main/resources/objectgrid.xml /opt/was/liberty/ObjectGrid/gettingstarted/server/config/.'
end

#update the env.sh file
template '/opt/was/liberty/ObjectGrid/gettingstarted/env.sh' do
  source 'env.sh.erb'
  owner 'root'
  group 'root'
  mode '0777'
  variables({
    :env_javahome_path => node[:wxs][:env][:javapath],
    :env_server_buildfiles_path => node[:wxs][:env][:buildfilespath][:server],
    :env_common_buildfiles_path => node[:wxs][:env][:buildfilespath][:common]
  })
end

#update the server.xml
template '/opt/was/liberty/wlp/usr/servers/server1/server.xml' do
  source 'server.xml.erb'
  owner 'wlp'
  group 'wlpadmin'
  mode '0644'
end

#start the catalog server
execute 'wxs_start_catalog' do
  command 'sudo nohup /opt/was/liberty/ObjectGrid/gettingstarted/runcat.sh &'
end

#start a database
execute 'wxs_start_container' do
  command 'sudo nohup /opt/was/liberty/ObjectGrid/gettingstarted/runcontainer.sh c0 &'
end

#start the webserver
wlp_server "server1" do
  clean true
  action :start
end

ruby_block 'load_users_to_db' do
  block do   
    require 'net/http'
    res = Net::HTTP.get_response(URI("http://localhost:9080/acmeair-webapp/rest/info/loader/load?numCustomers=#{node[:config][:webapp][:users_to_load]}"))
    if  res.body.include? "Loaded flights and"
    else
      raise "An error has occured: #{res.code} #{res.message}"
    end
  end
  retries 60
end