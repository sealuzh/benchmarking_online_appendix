#
# Cookbook Name:: cwb-monitoring
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

jstatd_logpath = node['cwb-monitoring']['jstatd']['log_path']
jstatd_rmi_port = node['cwb-monitoring']['jstatd']['rmi_port']

if node['cwb-monitoring']['jstatd']['enabled']
	ruby_block 'start_jstatd' do
	  block do
	  	Dir.chdir('/usr/lib/jvm/java-7-openjdk-amd64/lib') do
	 		File.open("#{jstatd_logpath}/log.log", "a+") {|f| f.puts("Log:")}

	    	hostname = %x[curl http://ipecho.net/plain]
	 		File.open("/usr/lib/jvm/java-7-openjdk-amd64/lib/all.policy", "w+") {|f| 
	 			f.write('grant codebase "file:tools.jar" {permission java.security.AllPermission;};') 
	 		}

	 		File.open("#{jstatd_logpath}/log.log", "a+") {|f| f.puts("hostname: #{hostname}")}

	 		#the rmi registry is created automatically if there is no registry running on the specified port
	 		system("sudo nohup jstatd -J-Djava.security.policy=all.policy -J-Djava.rmi.server.hostname=#{hostname} -p #{jstatd_rmi_port} &")

	 		i = 0
	 		netstat_output = %x[sudo netstat -tulpn | grep jstatd]
	 		while netstat_output.to_s.empty? or i < 10
	   			system('sleep 2s')
	   			netstat_output = %x[sudo netstat -tulpn | grep jstatd]
	   			i += 1
			end

	 		File.open("#{jstatd_logpath}/log.log", "a+") {|f| f.puts("netstat_output: #{netstat_output}")}
	 			
			netstat_output.scan(/:::.\d+/) {|m| 
				m.gsub!(/:::/,"")
	 			returnValue = %x[sudo ufw allow #{m}/tcp]
	 			File.open("#{jstatd_logpath}/log.log", "a+") {|f| 
	 				f.write("#{m}: ")
	 				f.puts("#{returnValue}")  
	 			}
			}
		end
	  end
	  action :run
	end
end

vmstat_logpath = node['cwb-monitoring']['vmstat']['log_path']
if node['cwb-monitoring']['vmstat']['enabled']
	ruby_block 'start_vmstat' do
	  block do
	 		system("sudo nohup vmstat 5 > #{vmstat_logpath}/vmstat.log &")
	  end
	  action :run
	end
end