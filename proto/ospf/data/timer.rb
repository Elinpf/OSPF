class Timer
	def initialize time
		@time = time
		@state = false
	end

	def change!
		@state = !@state
	end

	def run &block
		@state = true
		@fk = Thread.fork do
			loop do
				break if @state == false
				# first time to send
				yield
				@time.times do |t|
					if t == @time - 1
						yield
					end
					sleep 1
				end
			end
		end
	end

	def start  &block
		self.run &block
	end

	def stop
		@state = false
	end

	def time= time
		@time = time
	end
	
	def time
		@time
	end

	def alive?
		@fk.alive?
	end

	private
	def kill
		@fk.kill
	end
end

	


