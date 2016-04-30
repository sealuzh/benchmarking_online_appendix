#default['firewall']['allow_ssh'] = true
#default['cwb-jmeter']['open_ports'] = [80]
override[:java][:jdk_version] = 7

default['config']['hosts'] = '172.31.3.1'
default['config']['remotes'] = '127.0.0.1'

default['config']['jmeter']['slave'] = false