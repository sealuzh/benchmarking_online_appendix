require 'cwb'
require 'csv'
require 'logger'

class AcmeairSingle < Cwb::Benchmark
#declare the global logger
@logger = nil
@file_path = nil
	
	#this is the only method that is called by cwb
	def execute
		init_logger_and_path
		@logger.info "Benchmark execution started"

		Dir.chdir('/usr/share/jmeter/bin') do
			for i in 0..(benchmark_iterations-1)
				begin
					@logger.info "------ Iteration #{i} ------"
					delete_old_results

					if is_distributed
						@logger.info "Executing run_cmd_distributed_benchmark"
						system(run_cmd_distributed_benchmark)
					else
						@logger.info "Executing run_cmd_single"
						system(run_cmd_single)				
					end

					fail 'JMeter exited with non-zero value' unless $?.success?

					results = process_results

					#submit the metrics back to the cwb server
					@cwb.submit_metric('start_time', timestamp, results[:start_time])
					@cwb.submit_metric('end_time', timestamp, results[:end_time])
					@cwb.submit_metric('total_time', timestamp, results[:total_time])
					@cwb.submit_metric('total_response_time', timestamp, results[:total_response_time])
					@cwb.submit_metric('average_response_time', timestamp, results[:average_response_time])
					@cwb.submit_metric('total_latency', timestamp, results[:total_latency])
					@cwb.submit_metric('average_latency', timestamp, results[:average_latency])
					@cwb.submit_metric('average_processing_time', timestamp, results[:average_processing_time])
					@cwb.submit_metric('total_count', timestamp, results[:total_count])
					@cwb.submit_metric('num_failures', timestamp, results[:num_failures])
					@cwb.submit_metric('num_success', timestamp, results[:num_success])
					@cwb.submit_metric('failure_rate', timestamp, results[:failure_rate])
					@cwb.submit_metric('success_rate', timestamp, results[:success_rate])
					@cwb.submit_metric('failure_rate_percent', timestamp, results[:failure_rate_percent])
					@cwb.submit_metric('success_rate_percent', timestamp, results[:success_rate_percent])
					@cwb.submit_metric('results', timestamp, results.to_s)

					jtl_results=process_jtl_results
					@cwb.submit_metric('total_thread_count', timestamp, jtl_results[:total_thread_count])
					@cwb.submit_metric('singl_thread_counts', timestamp, jtl_results[:singl_thread_counts])
					@cwb.submit_metric('number_of_slaves', timestamp, jtl_results[:number_of_slaves])
					@cwb.submit_metric('jtl_results', timestamp, jtl_results.to_s)


					#save the metrics locally to a file
					metrics_file_name = @cwb.deep_fetch('acmeair-single', 'logging','metrics_file_name')
					File.open("#{@file_path}/#{metrics_file_name}", 'a+') {|f| f.puts(results) }
					@logger.info "Metrics saved to #{@file_path}/#{metrics_file_name}"
				
					if results_file_upload_enabled
						@logger.info "Uploading #{results_file} to fileserver"
						# system(upload_jtl_to_server_cmd(i))
						system(upload_file_to_server_cmd(i,results_file,results_file_name,results_file_type))
						fail 'Results file: upload failed' unless $?.success? 
					end

					if log_file_upload_enabled
						@logger.info "Uploading #{log_file} to fileserver"
						# system(upload_log_to_server_cmd(i))
						system(upload_file_to_server_cmd(i,log_file,log_file_name, log_file_type))
						fail 'Log file: upload failed' unless $?.success?
					end

				rescue => e
					@logger.error e
					raise
				end	
			end
		end
		
		@logger.info "Benchmark terminated successfully."
	end


	def init_logger_and_path
		file_path_in_config = @cwb.deep_fetch('acmeair-single', 'logging','file_path')
		execution_log_file_name = @cwb.deep_fetch('acmeair-single', 'logging','execution_log_file_name')

		if file_path_in_config.eql? "default"
			@file_path =  File.expand_path(File.dirname(__FILE__))
		else
			@file_path = file_path_in_config
		end

		@logger = Logger.new("#{@file_path}/#{execution_log_file_name}")
		@logger.formatter = proc do |severity, datetime, progname, msg|
		   "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%6N')} ##{Process.pid}]: #{msg}\n"
		end
	end

	#get time since epoch in miliseconds
	def timestamp
		(Time.now.to_f * 1000).to_i
	end

	def timestamp_formatted
		t = Time.now
		t = t.localtime.strftime "%Y-%m-%d_%H-%M-%S"
	end

	def run_cmd_single
		"jmeter -n -t #{testplan_file} -j #{log_file} -l #{results_file}"
	end

	def run_cmd_distributed_benchmark
		"#{run_cmd_single} -r"
	end

	def is_distributed
		@cwb.deep_fetch('acmeair-single', 'distributed_benchmark')
	end

	def testplan_file_name
		@cwb.deep_fetch('acmeair-single', 'testplan_file_name')
	end

	def testplan_file
		"#{testplan_file_name}.jmx"
	end

	def log_file_name
		@cwb.deep_fetch('acmeair-single', 'log_file_name')
	end

	def log_file_type
		"log"
	end

	def log_file
		"#{log_file_name}.#{log_file_type}"
	end

	def log_file_upload_enabled
		@cwb.deep_fetch('acmeair-single', 'log_file_upload_enabled')
	end

	def results_file_name
		@cwb.deep_fetch('acmeair-single', 'results_file_name')
	end

	def results_file_type
		'jtl'
	end

	def results_file
		"#{results_file_name}.#{results_file_type}"
	end

	def results_file_upload_enabled
		@cwb.deep_fetch('acmeair-single', 'results_file_upload_enabled')
	end

	def filserver_ip
		@cwb.deep_fetch('acmeair-single', 'fileserver','ip')
	end

	def fileserver_port
		@cwb.deep_fetch('acmeair-single', 'fileserver','port')
	end

	def fileserver_resource
		@cwb.deep_fetch('acmeair-single', 'fileserver','resource')
	end

	def delete_old_results
		File.delete(results_file) if File.exist?(results_file)
	end

	# def upload_jtl_to_server_cmd(iteration)
	# 	"curl -i -F file=@#{results_file} -F name='#{results_file_name}_#{iteration}_#{timestamp_formatted}.jtl' http://#{filserver_ip}:#{fileserver_port}/#{fileserver_resource}"
	# end

	# def upload_log_to_server_cmd(iteration)
	# 	"curl -i -F file=@#{log_file} -F name='#{log_file_name}_#{iteration}_#{timestamp_formatted}.log' http://#{filserver_ip}:#{fileserver_port}/#{fileserver_resource}"
	# end

	def upload_file_to_server_cmd(iteration, file, name, type)
		"curl -i -F file=@#{file} -F name='#{name}-iter#{iteration}-tst#{timestamp_formatted}.#{type}' http://#{filserver_ip}:#{fileserver_port}/#{fileserver_resource}"
	end

	def process_results
		total_count = 0
		total_response_time = 0
		total_latency = 0
		num_failures = 0
		num_success = 0
		start_time = 32503676400000 #Wed Jan 01 3000 00:00:00 GMT+0100
		end_time = 0

		CSV.foreach(results_file, {:headers => true}) do |row|
			total_count += 1
			total_response_time += row['elapsed'].to_i
			total_latency += row['Latency'].to_i
			(num_success += 1) if (row['success'] == 'true')
			(num_failures += 1) if (row['success'] != 'true')

			#get the start of first request
			if row['timeStamp'].to_i < start_time
				start_time = row['timeStamp'].to_i
			end

			#get the end of last request
			end_time_tmp = (row['timeStamp'].to_i + row['elapsed'].to_i)
			if end_time_tmp > end_time
			   end_time = end_time_tmp
			end
		end

		results = {
			start_time: start_time,
			end_time: end_time,
			total_time: (end_time-start_time),

			total_response_time:total_response_time,
			average_response_time: (total_response_time.to_f / total_count),
			total_latency: total_latency,
			average_latency: (total_latency.to_f / total_count),
			average_processing_time: ((total_response_time.to_f - total_latency.to_f) / total_count),

			total_count: total_count,
			num_failures: num_failures,
			num_success: num_success,

			#https://en.wikipedia.org/wiki/Failure_rate
			failure_rate: (num_failures.to_f / total_response_time),
			success_rate: (num_success.to_f / total_response_time),

			failure_rate_percent: (num_failures.to_f / total_count.to_f),
			success_rate_percent: (num_success.to_f / total_count.to_f)
		}
	end

	def benchmark_iterations
		@cwb.deep_fetch('acmeair-single','benchmark_iterations')
	end

	def process_jtl_results
		thread_groups = Hash.new
		time_stamp = 0
		CSV.foreach(results_file, {:headers => true}) do |row|
			#add the currentThreadGroup to the hash and update its allThread count
		   current_thread_name = row['threadName'].split(" ").first
		   thread_groups.store(current_thread_name, row['allThreads'].to_i)

		   #find out when the first error occured
		   if row['success'] != true.to_s
		   		time_stamp = row['timeStamp']
		   		break
		   end
		end

		number_of_slaves = thread_groups.length
		singl_thread_counts = thread_groups.values
		total_thread_count = singl_thread_counts.inject(0, :+)
		return { 
			total_thread_count: total_thread_count,
			singl_thread_counts: singl_thread_counts.to_s ,
			number_of_slaves: number_of_slaves
		}
	end
end