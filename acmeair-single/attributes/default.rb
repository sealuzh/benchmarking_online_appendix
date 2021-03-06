default['acmeair-single']['distributed_benchmark'] = false
default['acmeair-single']['benchmark_iterations'] = 1

#Files generated by the benchmark
default['acmeair-single']['logging']['file_path'] = 'default'
default['acmeair-single']['logging']['execution_log_file_name'] = 'benchmark-execution.log'
default['acmeair-single']['logging']['metrics_file_name'] = 'metrics.txt'

#Files used or generated by Jmeter
default['acmeair-single']['testplan_file_name'] = 'jmeter_testplan'
default['acmeair-single']['results_file_upload_enabled'] = true
default['acmeair-single']['results_file_name'] = 'jmeter_results'
default['acmeair-single']['log_file_upload_enabled'] = false
default['acmeair-single']['log_file_name'] = "jmeter_logfile"

#Fileserver settings
default['acmeair-single']['fileserver']['ip'] = '172.31.4.1'
default['acmeair-single']['fileserver']['port'] = '8080'
default['acmeair-single']['fileserver']['resource'] = 'upload'