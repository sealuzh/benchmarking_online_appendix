# Docs: https://docs.chef.io/config_rb_metadata.html
name             'cwb-timeout'
maintainer       'Christian Davatz'
maintainer_email 'crixx@davatz.eu'
license          'MIT'
description      'Installs/Configures cwb-timeout'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'cwb', '~> 0.1.0'
