default['firewall']['allow_ssh'] = true
default['morphia_server']['open_ports'] = 9080

override[:java][:jdk_version] = 7
override[:wlp][:install_method] = 'zip'
override[:wlp][:zip][:url] = 'https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/8.5.5.9/wlp-webProfile7-8.5.5.9.zip'
override[:wlp][:install_java] = 'false'

override[:mongodb][:package_version] = '2.6.9'

default['mongodb']['name'] = 'acmeair'
default['mongodb']['ip'] = 'localhost'
default['mongodb']['port'] = '27017'