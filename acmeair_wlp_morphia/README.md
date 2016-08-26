# acmeair_wlp_morphia

Installs the `AcmeAir` on IBM Websphere Liberty (`WLP`) and `MongoDB`.

## Attributes

See `attributes/default.rb`

## Info
This is an infrastructure cookbook - it install Websphere Liberty, MongoDB and AcmeAir.
The MongoDB is preloaded with 1 mio. users and some flights (July 2016 - September 2016). 
Please update the database before use. To this end, use the AcmeAir web interface or the script provided by AcmeAir. 

### acmeair_wlp_morphia::default

Add the `acmeair_wlp_morphia` default recipe to your Chef configuration in the Vagrantfile:

```ruby
  chef.add_recipe `acmeair_wlp_morphia`
  chef.json =
  {
    `morphia_server` => {
    	`open_ports` => 9080
    },
    `mongodb` => {
    	`name` => `acmeair`,
		`ip` => `localhost`,
		`port` => `27017`
	}
  }
```

## License and Authors

Author:: Christian Davatz (crixx)