PORT_WEBAPP = 9080

FILESERVER_IP = '52.59.112.61'

JMETER_SLAVES_NUM = 0
JMETER_NUM_THREADS = 5000
JMETER_RAMP_UP_TIME = 0
JMETER_DURATION = 600

USER_IN_DB= 1000000
BENCHMARK_ITERATIONS = 1

INSTANCE_TYPE_WEBAPP = 'n1-highcpu-4'
INSTANCE_TYPE_DB = 'n1-standard-1'
INSTANCE_TYPE_JMETER = 'n1-standard-1'

GCE_ZONE = "europe-west1-b"
GCE_SCOPES = ["cloud-platform"]

DEBIAN_USERNAME = 'admin'
DEBIAN_SSH_KEY_PATH =  "~/.ssh/google_compute_engine"
DEBIAN_IMAGE = 'debian-8-jessie-java'

INSTANCE_TYPE_WEBAPP_sanitized = INSTANCE_TYPE_WEBAPP.gsub(/[\W]+/,"_")
INSTANCE_TYPE_DB_sanitized = INSTANCE_TYPE_DB.gsub(/[\W]+/,"_")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider :google do |google, override|
    google.google_project_id = "cwb-applicationbenchmark"
    google.google_client_email = "[...]"
    google.google_json_key_location = "[...]"
  end
  
  config.vm.define "mongodb" do |mongodb|
        mongodb.ssh.username = DEBIAN_USERNAME
        mongodb.vm.synced_folder '.', '/vagrant', disabled: true
        mongodb.vm.provider :google do |google, override|
          google.name = "mongodb#{execution_id}"
          google.zone = GCE_ZONE
          google.machine_type = INSTANCE_TYPE_DB
          google.image = DEBIAN_IMAGE
          google.scopes = GCE_SCOPES
          override.ssh.username = DEBIAN_USERNAME
          override.ssh.private_key_path = DEBIAN_SSH_KEY_PATH
        end
  
        mongodb.vm.provision 'cwb', type: 'chef_client' do |chef|
        chef.node_name = "mongodb#{execution_id}"
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
      webapp.vm.provider :google do |google, override|
        google.name = "webapp#{execution_id}"
        google.zone = GCE_ZONE
        google.machine_type = INSTANCE_TYPE_WEBAPP
        google.image = DEBIAN_IMAGE
        google.scopes = GCE_SCOPES
        override.ssh.username = DEBIAN_USERNAME
        override.ssh.private_key_path = DEBIAN_SSH_KEY_PATH
      end
    
      #for GCE, we have to run another script that queries the IP of the mongo db node before provisioning the webapp
      webapp.vm.provision "file", source: "~/getIP.py", destination: "~/getIP.py"
      webapp.vm.provision "shell", inline: "python getIP.py mongodb#{execution_id} europe-west1-b"
      webapp.vm.provision 'cwb', type: 'chef_client' do |chef|
        chef.node_name = "webapp#{execution_id}"
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
            'ip_from_file' => true,
            'ip_file_path_name' => '/home/admin/ip.env',
            'name' => 'acmeair',
            'ip' => 'value should be overwritten!',
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
    jmetermaster.ssh.username = DEBIAN_USERNAME
    jmetermaster.vm.synced_folder '.', '/vagrant', disabled: true
    jmetermaster.vm.provider :google do |google, override|
      google.name = "jmetermaster#{execution_id}"
      google.zone = GCE_ZONE
      google.machine_type = INSTANCE_TYPE_JMETER
      google.image = DEBIAN_IMAGE
      google.scopes = GCE_SCOPES
      override.ssh.username = DEBIAN_USERNAME
      override.ssh.private_key_path = DEBIAN_SSH_KEY_PATH
    end

    #for GCE, we have to run another script that queries the IP of the webapp node before provisioning the JMeter Test Plan
    jmetermaster.vm.provision "file", source: "~/getIP.py", destination: "~/getIP.py"
    jmetermaster.vm.provision "shell", inline: "python getIP.py webapp#{execution_id} europe-west1-b"
    jmetermaster.vm.provision 'cwb', type: 'chef_client' do |chef|
      chef.node_name = "jmetermaster#{execution_id}"
      chef.add_recipe 'jm-acmeair-api'
      chef.add_recipe 'jm-acmeair-default-assets'
      chef.add_recipe 'acmeair-single'
      chef.add_recipe 'cwb-tuning'
      chef.add_recipe 'cwb-monitoring'
      chef.json =
      {
        'benchmark' => {
          'logging_enabled' =>true,
          'owner' => DEBIAN_USERNAME,
          'group' => DEBIAN_USERNAME
        },
        'cwbjmeter' => {
          'config' => {
            'remotes_from_file' => false,
            'remotes' => 'value should be overwritten!',
            'remotes_file_path_name' => '/home/admin/ip.env',
            'slave' => false,
            'ssh_username' => DEBIAN_USERNAME,
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
                'name' => 'value should be overwritten!',
                'name_from_file' => true,
                'file_path_name' => '/home/admin/ip.env'
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
          'distributed_benchmark' => false,
          'results_file_name' => "j_exid#{execution_id}-#{benchmark_name}-#{INSTANCE_TYPE_WEBAPP_sanitized}_#{INSTANCE_TYPE_DB_sanitized}-j#{JMETER_SLAVES_NUM}-thr#{JMETER_NUM_THREADS}-dur#{JMETER_DURATION}-rt#{JMETER_RAMP_UP_TIME}",
          'log_file_upload_enabled' => true,
          'log_file_name' => "l_exid#{execution_id}-#{benchmark_name}-#{INSTANCE_TYPE_WEBAPP_sanitized}_#{INSTANCE_TYPE_DB_sanitized}-j#{JMETER_SLAVES_NUM}-thr#{JMETER_NUM_THREADS}-dur#{JMETER_DURATION}-rt#{JMETER_RAMP_UP_TIME}", 
          'testplan_file_name' => "jmeter_testplan",
          'fileserver' => {
              'ip' => FILESERVER_IP
          }
        }
      }
    end
  end
end
