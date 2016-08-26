# acmeair_wlp_morphia_distributed

Installs the **Websphere Libery (WLP)** and deploys **AcmeAir** to it. This cookbook is intended for use together with the `acmeair_mongodb` cookbook and in an multi instance setting.

## Attributes
See `attributes/default.rb`   
For the deployment on GCE, the IP address of the MongoDB can be picked up from a file...

## Info
This is an infrastructure cookbook - it install and configures IBM Websphere Liberty and deploys the AcmeAir application on it.

### Related Cookbooks
- `acmeair_mongodb`

### acmeair_wlp_morphia_distributed::default

Add the `acmeair_wlp_morphia_distributed` default recipe to your Chef configuration in the Vagrantfile:

```ruby
  chef.add_recipe `acmeair_wlp_morphia_distributed`
  chef.json = { 
	'firewall' => {
		'ports' => PORT_WEBAPP
	},
	'config' => {
		'webapp' =>{
	  		'port' => {
	    		'http' => PORT_WEBAPP
	  		}
		},
		'tuning' => {
	  		'heap_xms' => '512m',
	  		'heap_xmx' => '3g' #addjust!
		}
	},
	'mongodb' => {
		'name' => 'acmeair',
		'ip' => IP_DB,
		'port' => 27017,
		'user' => {
		  'name' => 'acmeairusr',
		  'password' => 'Login4Acme!'
		}
	}
  }
```

## License and Authors
License: GNU General Public License v3.0  
Author: Christian Davatz (crixx)