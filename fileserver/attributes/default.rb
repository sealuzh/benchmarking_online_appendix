default['firewall']['allow_ssh'] = true
default['firewall']['ports'] = 8080

default['fileserver']['config']['ssh_username'] = 'vagrant'
override[:java][:jdk_version] = 7