=begin
  This is OSPF LS Acknowledge Packet

  Menu		:ospf_lsa_headers 	# LSA Headers for Menu Class
  String	:body			
=end

class OSPFLSAck < Struct.new(:ospf_lsa_headers, :body)
	include StructFu
	def initialize(args={})
		super(
			Menu.new(""),
			StructFu::String.new.read(args[:body]))

	end

	def to_s
		self.to_a.map {|x| x.to_s}.join
	end

	def read str
		force_binary str
		return self if str.nil?
		self.ospf_clear_lsa
		if str.size % 20 == 0
			num = str.size / 20
			offset = 0
			num.times do |t|
				tmp = Factory.create_lsa_header_packet.read(
						str[offset, 20])
				offset += 20
				self.ospf_inject_lsa tmp.menu
			end
		end
		self
	end

	def ospf_inject_lsa menu
		raise "Must input Menu Class" unless Menu === menu
		self['ospf_lsa_headers'].add menu
	end

	def ospf_clear_lsa
		self['ospf_lsa_headers'].clear
	end

	def ospf_lsa_headers; self['ospf_lsa_headers'].to_s; end
	def ospf_lsa_headers_p; self['ospf_lsa_headers'].to_pkt; end
	# Becareful to use this method
	# The menu @header must be Nil
	def ospf_lsa_headers=(menu)
		raise "Must input Menu Class" unless Menu === menu
		self['ospf_lsa_headers'] = menu
	end

	def ospf_lsa_p; self.ospf_lsa_headers_p; end

	def ospf_lsa_headers_readable
		num = self['ospf_lsa_headers'].size
		res = ""
		if num == 0
			res = "."
		else
			num.times do |t|
				res << "!"
			end
		end
		res
	end
end


include PacketFu
class OSPFLSAckPacket < Packet
	attr_accessor :eth_header, :ip_header, :ospf_header, :ospf_lsack
	def initialize(args={})
		pro_config = {
			:ip_proto => 89,
			'ospf_type' => 5 }
		args.merge!(pro_config)
		@eth_header  = Factory.create_eth_header(args)
		@ip_header   = Factory.create_ip_header(args)
		@ospf_header = Factory.create_ospf_header(args)
		@ospf_lsack  = Factory.create_ospf_lsack(args)

		@ospf_header.body = @ospf_lsack
		@ip_header.body = @ospf_header
		@eth_header.body = @ip_header

		@headers = [@eth_header, @ip_header, @ospf_header, @ospf_lsack]
		super
		self
	end
	
	def self.can_parse? str
		return false unless EthPacket.can_parse? str
		return false unless IPPacket.can_parse? str
		return false unless OSPFHeaderPacket.can_parse? str
		true
	end

	def read(str=nil, args={})
		raise "Can't parse #{self.class}" unless self.class.can_parse? str
		@eth_header.read str
		@ip_header.read str[14, str.size]
		@ospf_header.read str[14+20, str.size]
		@ospf_lsack.read str[58, str.size]

		super(args)
		self
	end
end
