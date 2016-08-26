# fileserver

Installs the a fileserver in order to provide a simple fileserver for storing test-results.

## Attributes
See `attributes/default.rb`

## Info
This is an infrastructure cookbook - it installs and configures a fileserver which allows an convenient way to POST files to. It is based, without modification (apart from the file size limit increase), from the Spring Boot Tutorial regarding storing files with Spring Boot. 

##Warning
There is no security policy in place - this fileserver is by default compleatelly unprotected!

### fileserver::default

Add the `fileserver` default recipe to your Chef configuration in the Vagrantfile:

```ruby
	chef.add_recipe `fileserver`
	chef.json = {
        'fileserver' => {
          'config' => {
            'ssh_username' => SSH_USERNAME
          }
        }
      }
```

## License and Authors
License: GNU General Public License v3.0  
Author: Christian Davatz (crixx)