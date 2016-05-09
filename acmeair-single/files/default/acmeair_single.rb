require 'cwb'
require 'csv'
require 'logger'

class AcmeairSingle < Cwb::Benchmark
@logger = 'benchmark-execution.log'
	
	def execute
		init_logger
		@logger.info "execute started"

		Dir.chdir('/usr/share/jmeter/bin') do
			delete_old_results

			if is_distributed
				@logger.info "--execute run_cmd_distributed_benchmark"
				system(run_cmd_distributed_benchmark)
			else
				@logger.info "--execute run_cmd_single"
				system(run_cmd_single)				
			end

			fail 'JMeter exited with non-zero value' unless $?.success?

			@logger.info "upload file to fileserver"
			system(upload_jtl_to_server)
			fail 'file upload failed' unless $?.success?

			results = process_results

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

			@logger.info results
		end
		
		@logger.info "execute terminated"
	end


	def init_logger
		@logger = Logger.new('benchmark-execution.log')
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
		"jmeter -n -t AcmeAir.jmx -j AcmeAir1.log -l AcmeAir1.jtl"
	end

	def run_cmd_distributed_benchmark
		"jmeter -n -t AcmeAir.jmx -j AcmeAir1.log -l AcmeAir1.jtl -r"
	end

	def is_distributed
		@cwb.deep_fetch('acmeair-single', 'distributed_benchmark')
	end

	def results_file_name
		'AcmeAir1'
	end

	def results_file
		"#{results_file_name}.jtl"
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

	def upload_jtl_to_server
		"curl -i -F file=@#{results_file_name} -F name='#{results_file_name}-#{timestamp_formatted}.jtl' http://#{filserver_ip}:#{fileserver_port}/#{fileserver_resource}"
	end

	def process_results
		#more metrics see http://jmeter-plugins.org/wiki/JMeterPluginsCMD/
		#http://stackoverflow.com/questions/18510846/jmeter-latency-vs-load-timesample-time

		total_count = 0
		total_response_time = 0
		total_latency = 0
		num_failures = 0
		num_success = 0
		start_time = 32503676400000 #Wed Jan 01 3000 00:00:00 GMT+0100
		end_time = 0

		CSV.foreach(results_file, headers:true) do |row|
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
end