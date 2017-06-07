=begin
  This class is Factory about OSPF
=end

class Factory
	def self.create_eth_header(args={})
		EthHeader.new(args).read(args[:eth])
	end

	def self.create_eth_header_packet(args={})
		EthPacket.new(args)
	end

	def self.create_ip_header(args={})
		IPHeader.new(args).read(args[:ip])
	end

	def self.create_ip_header_packet(args={})
		IPPacket.new(args)
	end

	##
	# OSPF Factory
	##
	def self.create_ospf_header(args={})
		OSPFHeader.new(args).read(args[:ospf])
	end

	def self.create_ospf_header_packet(args={})
		OSPFHeaderPacket.new(args)
	end

	def self.create_ospf_hello(args={})
		OSPFHello.new(args).read(args[:ospf_hello])
	end

	def self.create_ospf_hello_packet(args={})
		OSPFHelloPacket.new(args)
	end

	def self.create_ospf_dbd(args={})
		OSPFDBD.new(args).read(args[:ospf_dbd])
	end

	def self.create_ospf_dbd_packet(args={})
		OSPFDBDPacket.new(args)
	end

	def self.create_ospf_lsr(args={})
		OSPFLSR.new(args).read(args[:ospf_lsr])
	end

	def self.create_ospf_lsr_packet(args={})
		OSPFLSRPacket.new(args)
	end

	def self.create_ospf_lsu(args={})
		OSPFLSU.new(args).read(args[:ospf_lsu])
	end

	def self.create_ospf_lsu_packet(args={})
		OSPFLSUPacket.new(args)
	end

	def self.create_ospf_lsack(args={})
		OSPFLSAck.new(args).read(args['ospf_lsack'])
	end

	def self.create_ospf_lsack_packet(args={})
		OSPFLSAckPacket.new(args)
	end

	##
	# LSA Factory
	##
	def self.create_lsa_header(args={})
		LSAHeader.new(args).read(args[:lsa_header])
	end

	def self.create_lsa_header_packet(args={})
		LSAHeaderPacket.new(args)
	end

	# Each of lsa header type
	def self.create_lsa_header_packet_router(args={})
		type = {'ospf_lsa_lstype' => 1}
		args.merge!(type)
		self.create_lsa_header_packet(args)
	end

	def self.create_lsa_header_packet_network(args={})
		type = {'ospf_lsa_lstype' => 2}
		args.merge!(type)
		self.create_lsa_header_packet(args)
	end

	def self.create_lsa_header_packet_summary_ip(args={})
		type = {'ospf_lsa_lstype' => 3}
		args.merge!(type)
		self.create_lsa_header_packet(args)
	end

	def self.create_lsa_header_packet_summary_asbr(args={})
		type = {'ospf_lsa_lstype' => 4}
		args.merge!(type)
		self.create_lsa_header_packet(args)
	end

	def self.create_lsa_header_packet_external(args={})
		type = {'ospf_lsa_lstype' => 5}
		args.merge!(type)
		self.create_lsa_header_packet(args)
	end

	def self.create_lsa_header_packet_nssa(args={})
		type = {'ospf_lsa_lstype' => 7}
		args.merge!(type)
		self.create_lsa_header_packet(args)
	end

	##
	# Each LSA Type
	##

	# Router Lsa
	def self.create_lsa_router(args={})
		LSARouter.new(args).read(args[:lsa_router])
	end

	def self.create_lsa_router_packet(args={})
		LSARouterPacket.new(args)
	end

	def self.create_lsa_link(args={})
		LSALink.new(args).read(args[:lsa_link])
	end

	# Network Lsa
	def self.create_lsa_network(args={})
		LSANetwork.new(args).read(args[:lsa_network])
	end

	def self.create_lsa_network_packet(args={})
		LSANetworkPacket.new(args)
	end

	def self.create_lsa_attrouter(args={})
		Attrouter.new(args).read(args[:lsa_attrouter])
	end

	# Summary Lsa
	def self.create_lsa_summary(args={})
		LSASummary.new(args).read(args[:lsa_summary])
	end

	def self.create_lsa_summary_packet(args={})
		LSASummaryPacket.new(args)
	end

	def self.create_lsa_summary_ip_packet(args={})
		lsa_type = {'ospf_lsa_lstype' => 3}
		args.merge!(lsa_type)
		self.create_lsa_summary_packet(args)
	end

	def self.create_lsa_summary_asbr_packet(args={})
		lsa_type = {'ospf_lsa_lstype' => 4}
		args.merge!(lsa_type)
		self.create_lsa_summary_packet(args)
	end

	# External Lsa
	def self.create_lsa_external(args={})
		LSAExternal.new(args).read(args[:lsa_external])
	end

	def self.create_lsa_external_packet(args={})
		LSAExternalPacket.new(args)
	end

	##
	# Menu
	##
	def self.create_menu(menu="")
		Menu.new(menu)
	end

	def self.create_menu_item(menu="")
		MenuItem.new(menu)
	end
	# Use for instance factory
	def method_missing(method, args={})
		if self.class.respond_to? method.to_sym
			self.class.send(method.to_sym, args)
		else
			super
		end
	end
end
