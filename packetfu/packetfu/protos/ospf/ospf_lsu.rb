=begin
  This is OSPF LS Update Packet
  4Byte

  Int32		:ospf_lsanum		# Number of LSAs
  Menu		:ospf_lsa_packets	# LSAs
  String	:body		
=end

class OSPFLSU < Struct.new(
			:ospf_lsanum,
			:ospf_lsa_packets, :body)
	include StructFu
	def initialize(args={})
		super(
			Int32.new(args['ospf_lsanum'] || 0),
			Menu.new(""),
			StructFu::String.new.read(args[:body]))
	end

	def to_s
		self.to_a.map {|x| x.to_s}.join
	end

	def read str
		force_binary str
		return self if str.nil?
		self['ospf_lsanum'].read str[0,4]
		lsa_num = self.ospf_lsanum
		self.ospf_clear_lsa
		if lsa_num > 0
			offset = 4
			type = 0
			lsa_num.times do |t|
				type = str[offset + 3, 1].unpack("C").first
				len  = str[offset + 18,2].unpack("n").first
				if not [1,2,3,4,5,7].include? type
					raise "Can't parse #{self.class} type: #{type}"
				end
				type_f = LSAHeader.lstype_class_factory[type]
				tmp = Factory.send("create_#{type_f}_packet").read(
						str[offset, len])
				offset += len
				self.ospf_inject_lsa tmp.menu
			end
		end
		self
	end

	def ospf_lsanum; 	self['ospf_lsanum'].to_i; end
	def ospf_lsanum=(v);	typecast v; end

	def ospf_lsa_packets;	self['ospf_lsa_packets'].to_s; end
	def ospf_lsa_packets_p;	self['ospf_lsa_packets'].to_pkt; end
	def ospf_lsa_packets=(v)
		raise "Must input Menu Class" unless v.kind_of? Menu
		self['ospf_lsa_packets'] = v
	end
	# alias
	def ospf_lsa_p; self.ospf_lsa_packets_p; end

	# careful input Menu
	def ospf_inject_lsa menu
		# ospf_inject(lsa, /^LSA/)
		raise "Must input Menu Class" unless Menu === menu
		self['ospf_lsa_packets'].add menu
	end

	def ospf_clear_lsa
		self['ospf_lsa_packets'].clear
	end

	def ospf_lsa_packets_readable
		ospf_calc_lsanum
		res = ""
		if ospf_lsanum == 0
			res = "."
		else
			ospf_lsanum.times.each do |t|
				res << "!"
			end
		end
		res
	end

	def ospf_calc_lsanum
		self.ospf_lsanum = self['ospf_lsa_packets'].size
	end

	def ospf_calc_lsa
		self['ospf_lsa_packets'].ospf_recalc_lsa
	end

	def ospf_recalc_lsu(args = :all)
		case args
		when :lsasum
			self.ospf_calc_lsanum
		when :lsa
			self.ospf_calc_lsa
		when :all
			self.ospf_calc_lsa
			self.ospf_calc_lsanum
		else
			raise "Only :lsasum :lsa or :all"
		end
	end

end


include PacketFu
class OSPFLSUPacket < Packet
	attr_accessor :eth_header, :ip_header, :ospf_header, :ospf_lsu
	include PacketFu::Inject
	def initialize(args={})
		pro_config = {
			:ip_proto => 89,
			'ospf_type' => 4 }
		args.merge!(pro_config)
		@eth_header = Factory.create_eth_header(args)
		@ip_header  = Factory.create_ip_header(args)
		@ospf_header = Factory.create_ospf_header(args)
		@ospf_lsu   = Factory.create_ospf_lsu(args)
		
		@ospf_header.body = @ospf_lsu
		@ip_header.body = @ospf_header
		@eth_header.body = @ip_header

		@headers = [@eth_header, @ip_header, @ospf_header, @ospf_lsu]
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
		@ospf_lsu.read str[58, str.size]

=begin
		if lsanum > 0
			offset = 62
			type = 0
			lsa_tmp = []
			lsanum.times do |i|
				type = str[offset + 4, 1].unpack("C").first
				len =  str[offset + 19, 2].unpack("n").first
				type_f = LSAHeader.lstype_class_factory[type]
				lsa_tmp[i] = @factory.send("create_#{type_f}_packet").read(
						str[offset, len])
				offset += len
			end
			@headers = [@eth_header, @ip_header, @ospf_header, @ospf_lsu]
			@headers += lsa_tmp
		end
=end

			
		super(args)
		self
	end
end



