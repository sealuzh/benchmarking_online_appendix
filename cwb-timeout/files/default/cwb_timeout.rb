require 'cwb'

class CwbTimeout < Cwb::Benchmark
	def timeout
		@cwb.deep_fetch('cwb-timeout', 'timeout_in_minutes')
	end
	def execute
		system("sleep #{timeout}m")
	end
end