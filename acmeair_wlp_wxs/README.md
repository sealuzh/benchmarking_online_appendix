# acmeair_wlp_wxs

Installs the **Websphere Libery (WLP)** and deploys **AcmeAir** to it. Moreover the **Websphere Extreme Scale (WXS)** database is installed and configured.

## Attributes
See `attributes/default.rb`

## Info
This is an infrastructure cookbook - it install and configures IBM Websphere Liberty and deploys the AcmeAir application on it. As database, Websphere Extreme Scale is used.

### acmeair_wlp_wxs::default

Add the `acmeair_wlp_wxs` default recipe to your Chef configuration in the Vagrantfile:

```ruby
  chef.add_recipe `acmeair_wlp_wxs`
  chef.json = { 
	'config' => {
		'webapp' => {
			'users_to_load' => 200
		}
	}
  }
```

## License and Authors
License: GNU General Public License v3.0  
Author: Christian Davatz (crixx)