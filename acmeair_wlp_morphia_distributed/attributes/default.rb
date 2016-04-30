webapp_port = 9080

default['config']['webapp']['users_to_load'] = 200
default['config']['webapp']['port'] = webapp_port

default['mongodb']['name'] = 'acmeair'
default['mongodb']['ip'] = '172.31.2.1'
default['mongodb']['port'] = '27017'
default['mongodb']['user']['name'] = 'acmeairusr'
default['mongodb']['user']['password'] = 'Login4Acme!'

default['firewall']['allow_ssh'] = true
default['wlp_morphia_server']['open_ports'] = [webapp_port]

override[:java][:jdk_version] = 7
override[:wlp][:install_method] = 'zip'
override[:wlp][:zip][:url] = 'https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/8.5.5.9/wlp-webProfile7-8.5.5.9.zip'
override[:wlp][:install_java] = 'false'