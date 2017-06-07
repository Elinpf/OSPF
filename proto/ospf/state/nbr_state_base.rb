class ErrorPut
	def to_s
		puts "Error in this State"
	end
end
class State
	def initialize machine
		@machine = machine
	end

	def hello_received;	puts ErrorPut.new; end
	def start; 		puts ErrorPut.new; end
	def two_way_received;   puts ErrorPut.new; end
	def negotiation_done;	puts ErrorPut.new; end
	def exchange_done;	puts ErrorPut.new; end
	def bad_lsreq;		puts ErrorPut.new; end
	def loading_done;	puts ErrorPut.new; end
	def adj_ok?;		puts ErrorPut.new; end
	def seqnumber_mismatch; puts ErrorPut.new; end
	def one_way_received;   puts ErrorPut.new; end
	def kill_nbr;		puts ErrorPut.new; end
	def inactivity_timer;	puts ErrorPut.new; end
	def ll_down;		puts ErrorPut.new; end
end

class DownState < State
	def start
		puts "start to Attempt State"
		@machine.changeto_attempt_state
	end

	def hello_received
		puts "received a hello packet"
		@machine.changeto_init_state
	end

	def kill_nbr
	end

	def ll_down
	end

	def inactivity_timer
	end
end

class AttemptState < State
	def hello_received
		puts "received hellp packet -> Init"
		@machine.changeto_init_state
	end

	def kill_nbr
		@machine.changeto_down_state
	end
		
	def ll_down
		@machine.changeto_down_state
	end

	def inactivity_timer
		@machine.changeto_down_state
	end
end

class InitState < State
	def hello_received
	end

	def one_way_received
	end

	def two_way_received
		# switch: 2-way State or ExStart State
		puts "2-way received -> ExStart"
		@machine.changeto_exstart_state
	end

	def kill_nbr
		@machine.changeto_down_state
	end

	def ll_down
		@machine.changeto_down_state
	end

	def inactivity_timer
		@machine.changeto_down_state
	end
end

class TwoWayState < State
	def one_way_received
		@machine.changeto_init_state
	end

	def two_way_received
	end

	def hello_received
	end

	def adj_ok?
		# switch: don't change or change to ExStart
		@machine.changeto_exstart_state
	end

	def kill_nbr
		@machine.changeto_down_state
	end

	def ll_down
		@machine.changeto_down_state
	end

	def inactivity_timer
		@machine.changeto_down_state
	end
end

class ExStartState < State
	def adj_ok?
		@machine.changeto_two_way_state
	end

	def negotiation_done
		puts "negotiation done -> ExChange"
		@machine.changeto_exchange_state
	end

	def hello_received
	end

	def one_way_received
		@machine.changeto_init_state
	end

	def two_way_received
	end

	def kill_nbr
		@machine.changeto_down_state
	end

	def ll_down
		@machine.changeto_down_state
	end

	def inactivity_timer
		@machine.changeto_down_state
	end
end

class ExChangeState < State
	def seqnumber_mismatch
		@machine.changeto_exstart_state
	end

	def bad_lsreq
		@machine.changeto_exstart_state
	end

	def exchange_done
		# switch: Loading or Full
		puts "ExChange Done -> Loading or Full"
		@machine.changeto_loading_state
	end

	def adj_ok?
		@machine.changeto_two_way_state
	end

	def hello_received
	end

	def one_way_received
		@machine.changeto_init_state
	end

	def two_way_received
	end

	def kill_nbr
		@machine.changeto_down_state
	end

	def ll_down
		@machine.changeto_down_state
	end

	def inactivity_timer
		@machine.changeto_down_state
	end
end

class LoadingState < State
	def loading_done
		puts "Loading Done -> Full"
		@machine.changeto_full_state
	end

	def seqnumber_mismatch
		@machine.changeto_exstart_state
	end

	def adj_ok?
		@machine.changeto_two_way_state
	end

	def hello_received
	end

	def one_way_received
		@machine.changeto_init_state
	end

	def two_way_received
	end

	def kill_nbr
		@machine.changeto_down_state
	end

	def ll_down
		@machine.changeto_down_state
	end

	def inactivity_timer
		@machine.changeto_down_state
	end
end

class FullState < State
	def seqnumber_mismatch
		@machine.changeto_exstart_state
	end

	def adj_ok?
		@machine.changeto_two_way_state
	end

	def hello_received
	end

	def one_way_received
		@machine.changeto_init_state
	end

	def two_way_received
	end

	def kill_nbr
		@machine.changeto_down_state
	end

	def ll_down
		@machine.changeto_down_state
	end

	def inactivity_timer
		@machine.changeto_down_state
	end
end
