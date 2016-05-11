default['firewall']['allow_ssh'] = true
default['wxs_server']['open_ports'] = [80, 9080, 2809]

#template env.sh -> used in default-recipe
default['wxs']['env']['javapath'] = '/usr/lib/jvm/java-7-openjdk-amd64'
default['wxs']['env']['buildfilespath']['server'] = '/acmeair-buildfiles/acmeair-services-wxs/build/classes/main'
default['wxs']['env']['buildfilespath']['common'] = '/acmeair-buildfiles/acmeair-common/build/classes/main'

override[:java][:jdk_version] = 7

override[:wlp][:install_method] = 'zip'
override[:wlp][:zip][:url] = 'https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/8.5.5.9/wlp-webProfile7-8.5.5.9.zip'
override[:wlp][:install_java] = 'false'

default['config']['webapp']['users_to_load'] = 200

