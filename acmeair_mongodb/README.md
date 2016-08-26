# acmeair_mongodb

Installs the `MongoDB` and configures it for use with the AcmeAir benchmark application.

## Attributes

See `attributes/default.rb`

## Info
This is an infrastructure cookbook - it install and configures MongoDB.
The MongoDB is preloaded with 1 mio. users and some flights (July 2016 - September 2016). 
Please update the database before use. To this end, use the AcmeAir web interface or the script provided by AcmeAir. 

### acmeair_mongodb::default

Add the `acmeair_mongodb` default recipe to your Chef configuration in the Vagrantfile:

```ruby
  chef.add_recipe `acmeair_mongodb`
  chef.json =
  {
	`mongodb` => {
		`config` => {
			`bind_ip` => `0.0.0.0`,
			`port` => 27017
		}
	},
	`acmeairdb` => {
		`name` => `acmeair`,
		`user` => {
			`name` => `acmeairusr`,
			`password` => `Login4Acme!`
		}
	}
  }
```

## License and Authors
License: GNU General Public License v3.0
Author:: Christian Davatz (crixx)