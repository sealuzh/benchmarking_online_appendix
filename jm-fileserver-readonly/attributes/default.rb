
default['fileserverreadonly']['testplan']['connection_timeout'] = 30000 #30s
default['fileserverreadonly']['testplan']['response_timeout'] = 30000 #30s

default['fileserverreadonly']['testplan']['target_host']['port'] = 8080
default['fileserverreadonly']['testplan']['target_host']['name'] = '172.31.4.1'

default['fileserverreadonly']['testplan']['threadgroup']['num_threads'] = 1600
default['fileserverreadonly']['testplan']['threadgroup']['ramp_up_time'] = 600
default['fileserverreadonly']['testplan']['threadgroup']['duration'] = 600
default['fileserverreadonly']['testplan']['threadgroup']['delay'] = 0

#override and use the path jmeter_root
default['cwbjmeter']['config']['jmeter_root'] = "/usr/share/jmeter"