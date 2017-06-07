class SingleFactory
	def self.create_iface
		Interface.instance
	end
	
	def self.create_nbr
		Neighbor.instance
	end

	def self.create_machine
		NbrStateMachine.instance
	end

	def self.create_lsa_db
		LSADatabase.instance
	end
end
