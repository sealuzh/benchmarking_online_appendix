default['config']['webapp']['port']['http'] = 9080
default['config']['webapp']['port']['https'] = 9443

default['config']['tuning']['heap_xms'] = '256m'
default['config']['tuning']['heap_xmx'] = '512m'
default['config']['tuning']['max_keep_alive_requests'] = -1

default['mongodb']['name'] = 'acmeair'
default['mongodb']['ip'] = '172.31.2.1'
default['mongodb']['port'] = 27017
default['mongodb']['user']['name'] = 'acmeairusr'
default['mongodb']['user']['password'] = 'Login4Acme!'

default['firewall']['allow_ssh'] = true
default['firewall']['ports'] = 9080

override[:java][:jdk_version] = 7
override[:wlp][:install_method] = 'zip'
override[:wlp][:zip][:url] = 'https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/8.5.5.9/wlp-webProfile7-8.5.5.9.zip'
override[:wlp][:install_java] = 'false'