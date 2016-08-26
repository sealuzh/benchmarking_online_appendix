# jm-acmeair-api

Installs the a JMeter Test Plan which stresses the AcmeAir webservice API. 

## Attributes
See `attributes/default.rb`

## Info
This is a Workload cookbook, it provides the JMeter Test Plan required to stress the API. It allows to configure the number of concurrent users (threads) per JMeter instance, some timeouts, ramp-up-time and the test duration as well as some other configuration options. See attributes.

### Related Cookbooks
- jm-acmeair-**default**-assets (static files required for the Test Plan!)


### jm-acmeair-api::default

Add the `jm-acmeair-api` default recipe to your Chef configuration in the Vagrantfile:

```ruby
	chef.add_recipe `jm-acmeair-api`
      chef.json =
      {
          'acmeairapi' => {
            'testplan' => {
              'user_in_db' => USER_IN_DB,
              'connection_timeout' => 30000,
              'response_timeout' => 30000,
              'target_host' => {
                'port' => PORT_WEBAPP,
                'name' => IP_WEBAPP
              },
              'threadgroup' => {
                'num_threads' => JMETER_NUM_THREADS,
                'ramp_up_time' => JMETER_RAMP_UP_TIME,
                'duration' => JMETER_DURATION,
                'delay' => 0
              }
            }
          }
       }
```

## License and Authors
License: GNU General Public License v3.0  
Author: Christian Davatz (crixx)