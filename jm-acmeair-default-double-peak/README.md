# jm-acmeair-default-double-peak

Installs the a JMeter Test Plan which generates a workload showing a doubled peak. 

## Attributes
See `attributes/default.rb`

## Info
This is a Workload cookbook, it provides the JMeter Test Plan required to generate a double peaked workload. It allows to configure the number of concurrent users (threads) per JMeter instance, some timeouts, ramp-up-time and the test duration as well as some other configuration options. See attributes.

### Related Cookbooks
- jm-acmeair-default-double-peak-assets (static files required for the Test Plan!)

## License and Authors
License: GNU General Public License v3.0  
Author: Christian Davatz (crixx)