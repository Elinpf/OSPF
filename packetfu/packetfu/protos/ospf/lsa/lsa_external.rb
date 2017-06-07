=begin
  This is AS-external-LSA Packet
  16Byte

LSAHeader
-----------
LSAExternal
-----------
  Octets		:ospf_lsa_netmask	# Network Mask
  Int8			:ospf_lsa_e		# E bit
  Int8 			:void			# void
  Int16			:ospf_lsa_metric	# Metric
  Octets		:ospf_lsa_fwd		# Forwarding Address
  Int32			:ospf_lsa_tag		# External Route Tag
  String		:body

  Maybe have TOS information
  e bit
  TOS
  TOS metric
  Forwarding address
  External Route Tag
=end

class LSAExternal < Struct.new(
			:ospf_lsa_netmask,
			:ospf_lsa_e, :ospf_lsa_void, :ospf_lsa_metric,
			:ospf_lsa_fwd, :ospf_lsa_tag,
			:body)
	include StructFu
	def initialize(args={})
		super(
			Octets.new.read(args['ospf_lsa_netmask'] || "\x00"*4),
			Int8.new(args['ospf_lsa_e'] || 0),
			Int8.new(0),
			Int16.new(args['ospf_lsa_metric'] || 0),
			Octets.new(args['ospf_lsa_fwd'] || "\x00"*4),
			Int32.new(args['ospf_lsa_tag'] || 0),
			StructFu::String.new.read(args[:body]))
	end

	def to_s
		self.to_a.map {|x| x.to_s}.join
	end

	def read str
		force_binary str
		return self if str.nil?
		self['ospf_lsa_netmask'].read str[0,4]
		self['ospf_lsa_e'].read str[4,1]
		self['ospf_lsa_metric'].read str[6,2]
		self['ospf_lsa_fwd'].read str[8,4]
		self['ospf_lsa_tag'].read str[12,4]
		self['body'].read str[16,str.size] if str.size > 16
		self
	end

	def ospf_lsa_netmask; 	self['ospf_lsa_netmask'].to_i; end
	def ospf_lsa_netmask_str;	self['ospf_lsa_netmask'].to_s; end
	def ospf_lsa_netmask_quad;	self['ospf_lsa_netmask'].to_x; end
	def ospf_lsa_netmask_quad=(v);	self['ospf_lsa_netmask'].read_quad v; end
	def ospf_lsa_netmask=(v)
		case v
		when Octets
			self['ospf_lsa_netmask'] = v
		else
			typecast v
		end
	end

	def ospf_lsa_e;	self['ospf_lsa_e'].to_i; end
	def ospf_lsa_e_set;   self['ospf_lsa_e'].read 128; end
	def ospf_lsa_e_unset; self['ospf_lsa_e'].read 0; end
	def ospf_lsa_e_set?
		self['ospf_lsa_e'].to_i == 128 ? true : false
	end

	def ospf_lsa_metric; 	self['ospf_lsa_metric'].to_i; end
	def ospf_lsa_metric=(v);	typecast v; end
	
	def ospf_lsa_fwd; 	self['ospf_lsa_fwd'].to_i; end
	def ospf_lsa_fwd_str;	self['ospf_lsa_fwd'].to_s; end
	def ospf_lsa_fwd_quad;	self['ospf_lsa_fwd'].to_x; end
	def ospf_lsa_fwd_quad=(v);	self['ospf_lsa_fwd'].read_quad v; end
	def ospf_lsa_fwd=(v)
		case v
		when Octets
			self['ospf_lsa_fwd'] = v
		else
			typecast v
		end
	end

	def ospf_lsa_tag; 	self['ospf_lsa_tag'].to_i; end
	def ospf_lsa_tag=(v);	tyepcast v; end
	
	def ospf_lsa_void_readable
		"Null"
	end

	alias :ospf_lsa_fwd_readable :ospf_lsa_fwd_quad
	alias :ospf_lsa_netmask_readable :ospf_lsa_netmask_quad
end

include PacketFu
class LSAExternalPacket < Packet
	attr_accessor :lsa_header, :lsa_external
	def initialize(args={})
		lsa_type = {'ospf_lsa_lstype' => 5}
		args.merge!(lsa_type)
		@lsa_header   = Factory.create_lsa_header(args)
		@lsa_external = Factory.create_lsa_external(args)
		@lsa_header.body = @lsa_external
		
		@headers = [@lsa_header, @lsa_external]
		super
		@lsa_menu = Factory.create_menu(self)
		self
	end

	def self.can_parse? str
		return false unless LSAHeaderPacket.can_parse? str
		return false unless str[3,1] == "\x05"
		return false unless str.size >= 36
		true
	end

	def read(str=nil, args={})
		raise "Can't parse #{self.class}" unless self.class.can_parse? str
		@lsa_header.read str[0, 20]
		@lsa_external.read str[20, str.size]

		@lsa_header.body = @lsa_external
		super(args)
		@lsa_menu = Factory.create_menu(self)
		self
	end

	def menu
		@lsa_menu
	end
end
