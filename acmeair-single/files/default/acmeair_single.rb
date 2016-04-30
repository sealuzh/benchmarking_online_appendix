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
			system(run_cmd)
			fail 'JMeter exited with non-zero value' unless $?.success?
			results = process_results
			@cwb.submit_metric(metric_name, timestamp, results[:average_response_time])
			@cwb.submit_metric('average_response_time_inline', timestamp, results[:average_response_time])
			@cwb.submit_metric('average_latency', timestamp, results[:average_latency])
			@cwb.submit_metric('average_processing_time', timestamp, results[:average_processing_time])
			@cwb.submit_metric('num_failures', timestamp, results[:num_failures])
			@cwb.submit_metric('num_success', timestamp, results[:num_success])
			@cwb.submit_metric('failure_rate', timestamp, results[:failure_rate])
			@cwb.submit_metric('success_rate', timestamp, results[:success_rate])
			@cwb.submit_metric('total_count', timestamp, results[:total_count])
			@cwb.submit_metric('total_time', timestamp, results[:total_time])
			@cwb.submit_metric('results', timestamp, results.to_s)
		end
		
		@logger.info "execute terminated"
	end


	def init_logger
		@logger = Logger.new('benchmark-execution.log')
		@logger.formatter = proc do |severity, datetime, progname, msg|
		   "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%6N')} ##{Process.pid}]: #{msg}\n"
		end
	end

	def timestamp
		Time.now.to_i
	end

	def run_cmd
		"jmeter -n -t AcmeAir.jmx -j AcmeAir1.log -l AcmeAir1.jtl"
	end

	def results_file
		'AcmeAir1.jtl'
	end

	def metric_name
		@cwb.deep_fetch('acmeair-single', 'metric_name')
	end

	def delete_old_results
		File.delete(results_file) if File.exist?(results_file)
	end

	def process_results
		#more metrics see http://jmeter-plugins.org/wiki/JMeterPluginsCMD/
		#http://stackoverflow.com/questions/18510846/jmeter-latency-vs-load-timesample-time

		total_count = 0
		total_response_time = 0
		total_latency = 0
		num_failures = 0
		num_success = 0
		start_time = 32503676400 #3000-01-01 00:00:00 +0100
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
			total_count: total_count,
			average_response_time: (total_response_time.to_f / total_count),
			average_latency: (total_latency.to_f / total_count),
			average_processing_time: ((total_response_time.to_f - total_latency.to_f) / total_count),
			num_failures: num_failures,
			num_success: num_success,
			failure_rate: (num_failures.to_f / total_response_time),
			success_rate: (num_success.to_f / total_response_time),
			total_time: (end_time-start_time)
		}
	end
end