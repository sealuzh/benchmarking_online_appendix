default['firewall']['allow_ssh'] = true
default['firewall']['ports'] = 8080

default['fileserver']['config']['ssh_username'] = 'vagrant'
override[:java][:jdk_version] = 7

default['fileserver']['config']['heap_size_xms'] = '256m'
default['fileserver']['config']['heap_size_xmx'] = '512m'