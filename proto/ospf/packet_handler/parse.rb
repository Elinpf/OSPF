# Parse OSPF  Packet
class Parse
	attr_reader :type
	def initialize 
		# Fist just String Class
		@packet = nil
		# ospf type 
		@type = 0
	end

	def packet= str
		unless String === str
			raise "Input String for Parse Class"
		end
		@packet = str
	end

	def can_parse?
		unless @packet[12, 2].unpack("n").first == 2048
			puts "Not a IP Packet"
			return false
		end
		unless @packet[14, 1].unpack("C").first == 69
			puts "Not a IPv4 Packet"
			return false
		end
		
		ip = Factory.create_ip_header_packet.read @packet
		
		unless ip.ip_proto == 89
			puts "Not a OSPF Packet"
			return false
		end
		self.parse
		true
	end

	def parse
		ospf = Factory.create_ospf_header_packet.read @packet

		@type = ospf.ospf_type 
	end
	
	def is_hello?
		@type == 1 ? true : false
	end

	def is_dbd?
		@type == 2 ? true : false
	end

	def is_lsr?
		@type == 3 ? true : false
	end

	def is_lsu?
		@type == 4 ? true : false
	end

	def is_lsack?
		@type == 5 ? true : false
	end
end
		




		
