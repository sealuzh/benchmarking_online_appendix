default['acmeairapi']['testplan']['user_in_db'] = 200

default['acmeairapi']['testplan']['connection_timeout'] = 30000 #30s
default['acmeairapi']['testplan']['response_timeout'] = 30000 #30s

default['acmeairapi']['testplan']['target_host']['port'] = 9080
default['acmeairapi']['testplan']['target_host']['name'] = ''
default['acmeairapi']['testplan']['target_host']['name_from_file'] = false
default['acmeairapi']['testplan']['target_host']['file_path_name'] = '/target_ip.env'

default['acmeairapi']['testplan']['threadgroup']['num_threads'] = 500
default['acmeairapi']['testplan']['threadgroup']['ramp_up_time'] = 120
default['acmeairapi']['testplan']['threadgroup']['duration'] = 300
default['acmeairapi']['testplan']['threadgroup']['delay'] = 0

#override the jmeter sample_variables
default['cwbjmeter']['config']['user_properties']['sample_variables'] = 'FLIGHTTOCOUNT,FLIGHTRETCOUNT,ONEWAY'

#override and use the path jmeter_root
default['cwbjmeter']['config']['jmeter_root'] = "/usr/share/jmeter"