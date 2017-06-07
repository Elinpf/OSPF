class NbrStateMachine
	include Singleton
	def initialize
		@@down_state  	 = DownState.new self
		@@attempt_state	 = AttemptState.new self
		@@init_state	 = InitState.new self
		@@two_way_state	 = TwoWayState.new self
		@@exstart_state	 = ExStartState.new self
		@@exchange_state = ExChangeState.new self
		@@loading_state	 = LoadingState.new self
		@@full_state	 = FullState.new self

		@state = @@down_state
	end

	#
	# Event
	#
	def hello_received
		@state.hello_received
	end

	def start
		@state.start
	end

	def two_way_received
		@state.two_way_received
	end

	def negotiation_done
		@state.negotiation_done
	end

	def exchange_done
		@state.exchange_done
	end

	def bad_lsreq
		@state.bad_lsreq
	end

	def loadding_done
		@state.loadding_done
	end

	def adj_ok?
		@state.adj_ok?
	end

	def seqnumber_mismatch
		@state.seqnumber_mismatch
	end

	def one_way_received
		@state.one_way_received
	end

	def kill_nbr
		@state.kill_nbr
	end

	def inactivity_timer
		@state.inactivity_timer
	end

	def ll_down
		@state.ll_down
	end

	#
	# Contorl
	#
	def state
		@state
	end

	def state=(v)
		raise ArgumentError unless State === v
		@state = v
	end

	def changeto_down_state
		self.state = @@down_state
	end

	def changeto_attempt_state
		self.state = @@attempt_state
	end

	def changeto_init_state
		self.state = @@init_state
	end

	def changeto_two_way_state
		self.state = @@two_way_state
	end

	def changeto_exstart_state
		self.state = @@exstart_state
	end

	def changeto_exchange_state
		self.state = @@exchange_state
	end

	def changeto_loading_state
		self.state = @@loading_state
	end

	def changeto_full_state
		self.state = @@full_state
	end
end
