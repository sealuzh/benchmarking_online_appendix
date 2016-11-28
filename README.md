# Okta – an Approach and Case Study of Cloud Instance Type Selection for Multi-Tier Web Applications
This is the online appendix for the paper "Okta – an Approach and Case Study of Cloud Instance Type Selection for Multi-Tier Web Applications". For further information on single cookbooks please refer to the cookbooks readme files.

### Cookbooks used in the case study
* acmeair_mongodb - sets up the mongodb
* acmeair_wlp_morphia_distributed - sets up acmeair with wlp and mongodb driver but without a mongodb instance
* acmeair-single/ - this is the cwb-jmeter benchmark (works like an adapter for jmeter-cwb)
* jm-acmeair-api/ - this is the effective jmeter test plan which was used for the benchmarks
* jm-acmeair-default-assets/ - this are the files needed to run the test plan
* fileserver/ - this is a convenience cookbook which provides a fileserver based on spring-boot
* cwb-jmeter/ - this is a cookbook which sets up  jmeter and its dependencies (is used for both, master and slave instances)
 
### Other cookbooks
All the other cookbooks in this repository were used in development or for POCs

## Example of CWB-Vagrantconfigurations
Examples of complete CWB configurations can be found in the "sample configurations" subfolder in this repository