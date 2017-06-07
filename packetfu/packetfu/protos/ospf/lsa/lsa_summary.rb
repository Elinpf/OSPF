=begin
  This is LSA Summary IP or ASBR Packet
  Because IP is type 3 and ASBR is 4
  8Byte

LSAHeader
------------
LSASummary
------------
  Octets		:ospf_lsa_netmask	# Network Mask
  Int32			:ospf_lsa_metric	# Metric
  String		:body

 Maybe include TOS information 
  TOS and TOS Metric
=end

class LSASummary < Struct.new(
			:ospf_lsa_netmask, :ospf_lsa_metric, :body)
	include StructFu
	def initialize(args={})
		super(
			Octets.new.read(args['ospf_lsa_netmask'] || "\x00"*4),
			Int32.new(args['ospf_lsa_metric'] || 0),
			StructFu::String.new.read(args[:body]))
	end

	def to_s
		self.to_a.map {|x| x.to_s}.join
	end

	def read str
		force_binary str
		return self if str.nil?
		self['ospf_lsa_netmask'].read str[0,4]
		self['ospf_lsa_metric'].read  str[4,4]
		self['body'].read str[8,str.size] if str.size > 8
		self
	end

	def ospf_lsa_netmask; 		self['ospf_lsa_netmask'].to_i; end
	def ospf_lsa_netmask_str;	self['ospf_lsa_netmask'].to_s; end
	def ospf_lsa_netmask_quad;	self['ospf_lsa_netmask'].to_x; end
	def ospf_lsa_netmask_quad=(v);	self['ospf_lsa_netmask'].read_quead v; end
	def ospf_lsa_netmask=(v)
		case v
		when Octets
			self['ospf_lsa_netmask'] = v
		else
			typecast v
		end
	end

	def ospf_lsa_metric;	self['ospf_lsa_metric'].to_i; end
	def ospf_lsa_metric=(v);	typecast v; end

	alias :ospf_lsa_netmask_readable :ospf_lsa_netmask_quad
end

include PacketFu
class LSASummaryPacket < Packet
	attr_accessor :lsa_header, :lsa_summary
	def initialize(args={})
		lsa_type = {'ospf_lsa_lstype' => 3}
		if not args['ospf_lsa_lstype'] == 4
			args.merge!(lsa_type)
		end
		@lsa_header  = Factory.create_lsa_header(args)
		@lsa_summary = Factory.create_lsa_summary(args)
		@lsa_header.body = @lsa_summary

		@headers = [@lsa_header, @lsa_summary]
		super
		@lsa_menu = Factory.create_menu(self)
		self
	end

	def self.can_parse? str
		return false unless LSAHeaderPacket.can_parse? str
		return false unless str[3,1] == "\x03" or str[3,1] == "\x04"
		return false unless str.size >= 28
		true
	end

	def read(str=nil, args={})
		raise "Can't parse #{self.class}" unless self.class.can_parse? str
		@lsa_header.read str[0,20]
		@lsa_summary.read str[20,str.size]
		@lsa_header.body = @lsa_summary

		super(args)
		@lsa_menu = Factory.create_menu(self)
		self
	end

	def menu
		@lsa_menu
	end
end
