#default['firewall']['allow_ssh'] = true
#default['cwb-jmeter']['open_ports'] = [80]
override[:java][:jdk_version] = 7

#default['cwbjmeter']['config']['hosts'] = '172.31.3.1'
default['cwbjmeter']['config']['remotes'] = '127.0.0.1'
default['cwbjmeter']['config']['slave'] = false
default['cwbjmeter']['config']['ssh_username'] = 'ubuntu'


default['cwbjmeter']['target_host']['port'] = 9080
default['cwbjmeter']['target_host']['name'] = '172.31.3.1'

default['cwbjmeter']['threadgroup']['num_threads'] = 20
default['cwbjmeter']['threadgroup']['ramp_up_time'] = 20
default['cwbjmeter']['threadgroup']['duration'] = 300
default['cwbjmeter']['threadgroup']['delay'] = 0