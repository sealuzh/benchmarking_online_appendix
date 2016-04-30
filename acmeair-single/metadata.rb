# Docs: https://docs.chef.io/config_rb_metadata.html
name             'acmeair-single'
maintainer       'Christian Davatz'
maintainer_email 'crixx@davatz.eu'
license          'MIT'
description      'Installs/Configures acmeair-single'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'cwb', '~> 0.1.0'
depends 'apt', '~> 2.9.2'
