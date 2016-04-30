default['firewall']['allow_ssh'] = true
default['mongodb_server']['open_ports'] = [80]

override[:mongodb][:package_version] = '2.6.9'

default['conf']['mongod']['bind_ip'] = '0.0.0.0' 