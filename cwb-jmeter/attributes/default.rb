#default['firewall']['allow_ssh'] = true
#default['cwb-jmeter']['open_ports'] = [80]
override[:java][:jdk_version] = 7


default['cwbjmeter']['config']['remotes'] = '127.0.0.1'
default['cwbjmeter']['config']['remotes_from_file'] = false
default['cwbjmeter']['config']['remotes_file_path_name'] = "remotes_ip.env"
default['cwbjmeter']['config']['slave'] = false
default['cwbjmeter']['config']['ssh_username'] = 'ubuntu'

default['cwbjmeter']['config']['xms_heap_size'] = '512m'
default['cwbjmeter']['config']['xmx_heap_size'] = '900m'

default['cwbjmeter']['config']['user_properties']['sample_variables'] = ''
default['cwbjmeter']['config']['jmeter_root'] = "/usr/share/jmeter"