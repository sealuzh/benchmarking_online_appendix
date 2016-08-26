# cwb-jmeter

Installs **Apache JMeter**. No JMeter Test Plan included.

## Attributes
See `attributes/default.rb`

## Info
This is an infrastructure cookbook - it installs and configures JMeter. No Test Plan included, thus in order to generate load please also load one oft the related cookbooks too.  
For GCE, the IP addresses of the target and also of the remote-JMeter instances can be added vi a file. See attributes.

### Related Cookbooks
- jm-acmeair-default
- jm-acmeair-default-double-peak
- jm-acmeair-api
- jm-acmeair-readonly
- jm-acmeair-readwrite

### cwb-jmeter::default

Add the `cwb-jmeter` default recipe to your Chef configuration in the Vagrantfile:

```ruby
	chef.add_recipe `cwb-jmeter`
	chef.json =  {
	    'cwbjmeter' => {
	      'config' => {
	        'remotes' => jmeter_remotes,
	        'slave' => false,
	        'ssh_username' => UBUNTU_USERNAME,
	        'xms_heap_size' => '512m',
	        'xmx_heap_size' => '3g' #adapt acoordingly
	      }
	    }
	}
```

## License and Authors
License: GNU General Public License v3.0  
Author: Christian Davatz (crixx)