IP_DB = "172.31.2.#{benchmark_id}"
IP_WEBAPP = "172.31.3.#{benchmark_id}"
PORT_WEBAPP = 9080

JMETER_SLAVES_NUM = 2
JMETER_NUM_THREADS = 2500
JMETER_RAMP_UP_TIME = 0
JMETER_DURATION = 1200

USER_IN_DB= 1000000
BENCHMARK_ITERATIONS = 1

INSTANCE_TYPE_WEBAPP = 'c4.large'
INSTANCE_TYPE_DB = 't2.medium'

ubuntu_ami = 'ami-d19e79be'
UBUNTU_USERNAME = 'ubuntu'
debian8_4 = 'ami-e05ab38f'
DEBIAN_USERNAME = 'admin' # sudo -i

IMAGE_WEBAPP = debian8_4
IMAGE_DB = debian8_4

JMETER_BASE_IP = '172.31.15.' 
IP_JMETER_MASTER = "172.31.15."+(benchmark_id+100).to_s
#JMETER_BASE_IP+(JMETER_SLAVES_NUM+1).to_s

AWS_REG = 'eu-central-1'
AWS_A_ZONE = 'eu-central-1a'
AWS_SEC_GROUPS = ['cwb-web']

def jmeter_remotes
  remotes = ""
  for i in 1..JMETER_SLAVES_NUM
    remotes +=  (JMETER_BASE_IP+"#{i},")
  end
  return remotes
end

INSTANCE_TYPE_WEBAPP_sanitized = INSTANCE_TYPE_WEBAPP.gsub(/[\W]+/,"_")
INSTANCE_TYPE_DB_sanitized = INSTANCE_TYPE_DB.gsub(/[\W]+/,"_")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "mongodb" do |mongodb|
        mongodb.ssh.username = DEBIAN_USERNAME
        mongodb.vm.synced_folder '.', '/vagrant', disabled: true
        mongodb.vm.provider :aws do |aws, override|
          aws.region = AWS_REG
          aws.availability_zone = AWS_A_ZONE
          aws.ami = IMAGE_DB
          aws.instance_type = INSTANCE_TYPE_DB
          aws.security_groups = AWS_SEC_GROUPS
          aws.private_ip_address = IP_DB
          aws.tags = {
            'CWB_Function' => 'acmeair-mongodb'
          }
        end
  
        mongodb.vm.provision 'cwb', type: 'chef_client' do |chef|
        chef.node_name = 'mongodb'+execution_id.to_s
        chef.add_recipe 'acmeair_mongodb'
        chef.json =
        { 
          'benchmark' => {
            'logging_enabled' =>true,
            'owner' => DEBIAN_USERNAME,
            'group' => DEBIAN_USERNAME
          }
        }
      end
    end
  
    config.vm.define "webapp" do |webapp|
      webapp.vm.synced_folder '.', '/vagrant', disabled: true
      webapp.ssh.username = DEBIAN_USERNAME
      webapp.vm.provider :aws do |aws, override|
        aws.region = AWS_REG
        aws.availability_zone = AWS_A_ZONE
        aws.ami = IMAGE_WEBAPP
        aws.instance_type = INSTANCE_TYPE_WEBAPP
        aws.security_groups = AWS_SEC_GROUPS
        aws.private_ip_address = IP_WEBAPP
        aws.tags = {
          'CWB_Function' => 'acmeair-morphia-webapp'
        }
      end
    
      webapp.vm.provision 'cwb', type: 'chef_client' do |chef|
        chef.node_name = 'webapp'+execution_id.to_s
        chef.add_recipe 'acmeair_wlp_morphia_distributed'
        chef.add_recipe 'cwb-tuning'
        chef.add_recipe 'cwb-monitoring'
        chef.json =
        { 
          'benchmark' => {
            'logging_enabled' =>true,
            'owner' => DEBIAN_USERNAME,
            'group' => DEBIAN_USERNAME
          },
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
              'heap_xmx' => '3g'
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
      end
    end
    
  config.vm.define "jmetermaster", primary: true do |jmetermaster|
    jmetermaster.ssh.username = UBUNTU_USERNAME
    jmetermaster.vm.provider :aws do |aws, override|
        aws.region = AWS_REG
        aws.availability_zone = AWS_A_ZONE
        aws.ami = 'ami-d19e79be'
        aws.instance_type = 't2.medium'
        aws.security_groups = AWS_SEC_GROUPS
        aws.private_ip_address = IP_JMETER_MASTER
        aws.tags = {
          'CWB_Function' => 'jmetermaster'
        }
      end

    jmetermaster.vm.provision 'cwb', type: 'chef_client' do |chef|
      chef.node_name = 'jmetermaster-'+execution_id.to_s
      chef.add_recipe 'jm-acmeair-api'
      chef.add_recipe 'jm-acmeair-default-assets'
      chef.add_recipe 'acmeair-single'
      chef.add_recipe 'cwb-tuning'
      chef.add_recipe 'cwb-monitoring'
      chef.json =
      {
        'benchmark' => {
            'logging_enabled' =>true
        },
        'cwbjmeter' => {
          'config' => {
            'remotes' => jmeter_remotes,
            'slave' => false,
            'ssh_username' => UBUNTU_USERNAME,
            'xms_heap_size' => '512m',
            'xmx_heap_size' => '3g'
          }
        },
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
          },
        'acmeair-single' => {
          'benchmark_iterations' => BENCHMARK_ITERATIONS,
          'distributed_benchmark' => true,
          'results_file_name' => "j_exid#{execution_id}-#{benchmark_name}-#{INSTANCE_TYPE_WEBAPP_sanitized}_#{INSTANCE_TYPE_DB_sanitized}-j#{JMETER_SLAVES_NUM}-thr#{JMETER_NUM_THREADS}-dur#{JMETER_DURATION}-rt#{JMETER_RAMP_UP_TIME}",
          'log_file_upload_enabled' => true,
          'log_file_name' => "l_exid#{execution_id}-#{benchmark_name}-#{INSTANCE_TYPE_WEBAPP_sanitized}_#{INSTANCE_TYPE_DB_sanitized}-j#{JMETER_SLAVES_NUM}-thr#{JMETER_NUM_THREADS}-dur#{JMETER_DURATION}-rt#{JMETER_RAMP_UP_TIME}", 
          'testplan_file_name' => "jmeter_testplan"
          }
      }
    end
  end
  
end