SSH_USERNAME = 'ubuntu'
# after this time the slaves will terminate. actually not needed, cwb has also a timeout option
TIMEOUT_IN_MINUTES = 110 

JMETER_SLAVES_NUM = 20 # will start 20 slave instances!

# the ips are calculated, make sure in the other vagrant files they are calculated the same!
JMETER_BASE_IP = '172.31.15.'
IP_JMETER_MASTER = JMETER_BASE_IP+(JMETER_SLAVES_NUM+1).to_s

AWS_REG = 'eu-central-1'
AWS_A_ZONE = 'eu-central-1a'
AWS_SEC_GROUPS = ['cwb-web']

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.username = SSH_USERNAME
  
  (1..JMETER_SLAVES_NUM).each do |i|
    if i == 1
      config.vm.define "jmeterslave#{i}", primary: true do |jmeterslave|
        jmeterslave.vm.synced_folder '.', '/vagrant', disabled: true
        jmeterslave.vm.provider :aws do |aws, override|
          aws.region = AWS_REG
          aws.availability_zone = AWS_A_ZONE
          aws.ami = 'ami-d19e79be'
          aws.instance_type = 't2.small'
          aws.security_groups = AWS_SEC_GROUPS
          aws.private_ip_address = JMETER_BASE_IP+"#{i}"
          aws.tags = {
            'CWB_Function' => "jmeterslave#{i}"
          }
        end
                
        jmeterslave.vm.provision 'cwb', type: 'chef_client' do |chef|
          chef.node_name = "jmeterslave#{i}-"+execution_id.to_s
          chef.add_recipe 'cwb-jmeter'
          chef.add_recipe 'jm-acmeair-default-assets'
          chef.add_recipe 'cwb-timeout'
          chef.add_recipe 'cwb-tuning'
          chef.add_recipe 'cwb-monitoring'
          chef.json =
          {
            'cwbjmeter' => {
              'config' => {
                'remotes' => '',
                'slave' => true,
                'ssh_username' => SSH_USERNAME,
                'xms_heap_size' => '512m',
                'xmx_heap_size' => '1024m'
              }
            },
            'cwb-timeout' => {
              'timeout_in_minutes' => TIMEOUT_IN_MINUTES
              },
            'cwb-monitoring' => {
              'jstatd' => {
                'rmi_port' => 2020
              }
            }
          }
        end
      end
    else
      config.vm.define "jmeterslave#{i}" do |jmeterslave|
        jmeterslave.vm.synced_folder '.', '/vagrant', disabled: true
        jmeterslave.vm.provider :aws do |aws, override|
          aws.region = AWS_REG
          aws.availability_zone = AWS_A_ZONE
          aws.ami = 'ami-d19e79be'
          aws.instance_type = 't2.small'
          aws.security_groups = AWS_SEC_GROUPS
          aws.private_ip_address = JMETER_BASE_IP+"#{i}"
          aws.tags = {
            'CWB_Function' => "jmeterslave#{i}"
          }
        end
                
        jmeterslave.vm.provision 'cwb', type: 'chef_client' do |chef|
          chef.node_name = "jmeterslave#{i}-"+execution_id.to_s
          chef.add_recipe 'cwb-jmeter'
          chef.add_recipe 'jm-acmeair-default-assets'
          chef.add_recipe 'cwb-tuning'
          chef.add_recipe 'cwb-monitoring'
          chef.json =
          {
            'cwbjmeter' => {
              'config' => {
                'remotes' => '',
                'slave' => true,
                'ssh_username' => SSH_USERNAME,
                'xms_heap_size' => '512m',
                'xmx_heap_size' => '1024m'
              }
            },
            'cwb-monitoring' => {
              'jstatd' => {
                'rmi_port' => 2020
              }
            }
          }
        end
      end
    end
  end
end