#default['firewall']['allow_ssh'] = true
#default['cwb-jmeter']['open_ports'] = [80]
override[:java][:jdk_version] = 7

#default['cwbjmeter']['config']['hosts'] = '172.31.3.1'
default['cwbjmeter']['config']['remotes'] = '127.0.0.1'
default['cwbjmeter']['config']['slave'] = false
default['cwbjmeter']['config']['ssh_username'] = 'ubuntu'

#actually we could split up the config into two distinct modes: master and slave