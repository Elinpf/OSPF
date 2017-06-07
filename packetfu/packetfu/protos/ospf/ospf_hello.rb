=begin
 This is OSPF Hello Packet Base
 24 Byte
 
 Octets 	ospf_netmask	# Network Mask
 Int16		ospf_hi		# Hello Interval
 Opt		ospf_opt	# Options
 Int8		ospf_pri	# Router Priority
 Int32		ospf_rdead	# Router Dead Interval
 Octets		ospf_dr		# Designated Router
 Octets 	ospf_bdr	# Backup Designated Router
 Octets		ospf_nbr	# Neighbor +
 String		body

=end

class OSPFHello < Struct.new(
		:ospf_netmask,
		:ospf_hi, :ospf_opt, :ospf_pri,
		:ospf_rdead,
		:ospf_dr,
		:ospf_bdr,
		:ospf_nbr,
		:body)
	
	include StructFu
	def initialize(args={})
		super(
			Octets.new.read(args['ospf_netmask'] || "\x00\x00\x00\x00"),
			Int16.new(args['ospf_hi'] || 10),
			Opt.new(args['ospf_opt'] || 0),
			Int8.new(args['ospf_pri'] || 1),
			Int32.new(args['ospf_rdead'] || 40),
			Octets.new(args['ospf_dr'] || "\x00\x00\x00\x00"),
			Octets.new(args['ospf_bdr'] || "\x00\x00\x00\x00"),
			Octets.new(args['ospf_nbr'] || "\x00\x00\x00\x00"),
			StructFu::String.new.read(args[:body]))
	end

	def to_s
		self.to_a.map {|x| x.to_s}.join
	end

	def read str
		force_binary str
		return self if str.nil?
		self['ospf_netmask'].read str[0,4]
		self['ospf_hi'].read 	str[4,2]
		self['ospf_opt'].read 	str[6,1]
		self['ospf_pri'].read 	str[7,1]
		self['ospf_rdead'].read str[8,4]
		self['ospf_dr'].read 	str[12,4]
		self['ospf_bdr'].read 	str[16,4]
		self['ospf_nbr'].read	str[20,4]
		self['body'].read	str[24,str.size] if str.size > 24
		self
	end

	def ospf_netmask; self['ospf_netmask'].to_i; end
	def ospf_netmask=(v)
		case v
		when Octets
			self['ospf_netmask'] = v
		else
			typecast v
		end
	end

	def ospf_hi;	self['ospf_hi'].to_i; end
	def ospf_hi=(v);	typecast v; end

	def ospf_opt; 	self['ospf_opt'].to_i; end
	def ospf_opt=(v);	typecast v; end

	def ospf_pri;	self['ospf_pri'].to_i; end
	def ospf_pri=(v); 	typecast v; end

	def ospf_rdead;	self['ospf_rdead'].to_i; end
	def ospf_rdead=(v);	typecast v; end

	def ospf_dr;	self['ospf_dr'].to_i; end
	def ospf_dr=(v)
		case v
		when Octets
			self['ospf_dr'] = v
		else
			typecast v
		end
	end

	def ospf_bdr; self['ospf_bdr'].to_i; end
	def ospf_bdr=(v)
		case v
		when Octets
			self['ospf_bdr'] = v
		else
			typecast v
		end
	end

	# This Neighbor method  just for One , But Infact has more, so ...
	def ospf_nbr; self['ospf_nbr'].to_i; end
	def ospf_nbr=(v)
		case v
		when Octets
			self['ospf_nbr'] = v
		else
			typecast v
		end
	end


	# DN, O, DC, L, NP, MC, E, MT
	def ospf_opt_set(*opts)
		self['ospf_opt'].opt_set(opts)
	end

	# DN, O, DC, L, NP, MC, E, MT
	def ospf_opt_unset(*opts)
		self['ospf_opt'].opt_unset(opts)
	end

	def ospf_opt_set?(flag)
		self['ospf_opt'].has_set?(flag)
	end

	def ospf_opt_readable
		self['ospf_opt'].readable
	end

	def ospf_netmask_str;	   self['ospf_netmask'].to_s; end
	def ospf_netmask_quad;	   self['ospf_netmask'].to_x; end
	def ospf_netmask_quad=(v); self['ospf_netmask'].read_quad v; end

	def ospf_dr_str;	self['ospf_dr'].to_s; end
	def ospf_dr_quad;	self['ospf_dr'].to_x; end
	def ospf_dr_quad=(v);	self['ospf_dr'].read_quad v; end

	def ospf_bdr_str;	self['ospf_bdr'].to_s; end
	def ospf_bdr_quad;	self['ospf_bdr'].to_x; end
	def ospf_bdr_quad=(v);	self['ospf_bdr'].read_quad v; end

	def ospf_nbr_str;	self['ospf_nbr'].to_s; end
	def ospf_nbr_quad;	self['ospf_nbr'].to_x; end
	def ospf_nbr_quad=(v);	self['ospf_nbr'].read_quad v; end

	alias :ospf_netmask_readable	:ospf_netmask_quad
	alias :ospf_dr_readable 	:ospf_dr_quad
	alias :ospf_bdr_readable	:ospf_bdr_quad
	alias :ospf_nbr_readable	:ospf_nbr_quad
end

include PacketFu
class OSPFHelloPacket < Packet
	attr_accessor :eth_header, :ip_header, :ospf_header, :ospf_hello
	def initialize(args={})
		pro_config = { 
			:ip_proto => 89,
			'ospf_type' => 1}
		args.merge!(pro_config)
		@eth_header = Factory.create_eth_header(args)
		@ip_header  = Factory.create_ip_header(args)
		@ospf_header = Factory.create_ospf_header(args)
		@ospf_hello = Factory.create_ospf_hello(args)

		@ospf_header.body = @ospf_hello
		@ip_header.body = @ospf_header
		@eth_header.body = @ip_header

		@headers = [@eth_header, @ip_header, @ospf_header, @ospf_hello]
		super
	end

	def self.can_parse? str
		return false unless str.size >= 82
		return false unless EthPacket.can_parse? str
		return false unless IPPacket.can_parse?	str
		return false unless OSPFHeaderPacket.can_parse? str
  		# ospf type == 1
		return false unless str[35, 1] == "\x01"
		true
	end

	def read(str=nil, args={})
		raise "Can't parse `#{str}'" unless self.class.can_parse? str	
		@eth_header.read str
		@ip_header.read str[14, str.size]
		@ospf_header.read str[14+20, str.size]
		@ospf_hello.read str[14+20+24, str.size]

		@ospf_header.body = @ospf_hello
		@ip_header.body = @ospf_header
		@eth_header.body = @ip_header
		super(args)
		self
	end
end
		
		
	

