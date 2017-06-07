=begin
  This class is LS Request Packet
  12Byte

  Int32 	:ospf_lstype	# LS type
  Octets	:ospf_lsid	# Link State ID
  Octets	:ospf_ar	# Advertising Router
=end

class OSPFLSR < Struct.new(
		:ospf_lstype, :ospf_lsid, :ospf_ar,
		:body)
	include StructFu
	def initialize(args={})
		super(
			Int32.new(args['ospf_lstype'] || 1),
			Octets.new.read(args['ospf_lsid'] || "\x00\x00\x00\x00"),
			Octets.new.read(args['ospf_ar'] || "\x00\x00\x00\x00"),
			StructFu::String.new.read(args[:body]))
		@@lsa_type = LSAHeader.lstype_class
	end

	def to_s
		self.to_a.map {|x| x.to_s}.join
	end

	def read str
		force_binary str
		return self if str.nil?
		self['ospf_lstype'].read str[0,4]
		self['ospf_lsid'].read   str[4,4]
		self['ospf_ar'].read     str[8,4]
		self['body'].read str[12,str.size] if str.size > 12
		self
	end

	# Adapter
	def menu
		self
	end

	def ospf_lstype; 	self['ospf_lstype'].to_i; end
	def ospf_lstype=(v); 	typecast v; end
	def ospf_lstype_readable
		@@lsa_type[ospf_lstype]
	end

	def ospf_lsid; 		self['ospf_lsid'].to_i; end
	def ospf_lsid=(v)
		case v
		when Octets
			self['ospf_lsid'] = v
		else
			typecast v
		end
	end

	def ospf_ar;		self['ospf_ar'].to_i; end
	def ospf_ar=(v)
		case v
		when Octets
			self['ospf_ar'] = v
		else
			typecast v
		end
	end

	def ospf_lsid_str; 	self['ospf_lsid'].to_s; end
	def ospf_lsid_quad;	self['ospf_lsid'].to_x; end
	def ospf_lsid_quad=(v); self['ospf_lsid'].read_quad v; end

	def ospf_ar_str;	self['ospf_ar'].to_s; end
	def ospf_ar_quad;	self['ospf_ar'].to_x; end
	def ospf_ar_quad=(v);	self['ospf_ar'].read_quad v; end

	alias :ospf_lsid_readable :ospf_lsid_quad
	alias :ospf_ar_readable	:ospf_ar_quad
end

include PacketFu
class OSPFLSRPacket < Packet
	attr_accessor :eth_header, :ip_header, :ospf_header, :ospf_lsr
	include PacketFu::Inject
	def initialize(args={})
		pro_config = {
			:ip_proto => 89,
			'ospf_type' => 3 }
		args.merge!(pro_config)
		@eth_header = Factory.create_eth_header(args)
		@ip_header  = Factory.create_ip_header(args)
		@ospf_header = Factory.create_ospf_header(args)
		@ospf_lsr   = Factory.create_ospf_lsr(args)

		@ospf_header.body = @ospf_lsr
		@ip_header.body = @ospf_header
		@eth_header.body = @ip_header

		@headers = [@eth_header, @ip_header, @ospf_header, @ospf_lsr]
		super
		self
	end

	def ospf_inject_lsr lsr
		ospf_inject(lsr, /^OSPFLSR$/)
	end

	def ospf_get_lsr index
		@headers[3 + index]
	end

	def ospf_lsa_num
		@headers.size - 3
	end

	def self.can_parse? str
		return false unless EthPacket.can_parse? str
		return false unless IPPacket.can_parse? str
		return false unless OSPFHeaderPacket.can_parse? str
		((str.size - 58) % 12 == 0) ? true : false
	end
		
	def read(str=nil, args={})
		raise "Can't parse #{self.class}" unless self.class.can_parse? str
		@eth_header.read str
		@ip_header.read str[14,str.size]
		@ospf_header.read str[14+20, str.size]
		offset = 58
		if (str.size - offset) > 0
			lsr_num = (str.size - 58) / 12
			# [3, 2, 1, 0]
			tmp_lsr = []
			(0...lsr_num).to_a.reverse.each do |i|
				tmp_offset = offset + (12 * i)
				tmp_lsr[i] = Factory.create_ospf_lsr.read(
						str[tmp_offset, 12])
				if i != (lsr_num - 1)
					tmp_lsr[i].body = tmp_lsr[i-1]
				end
			end
			@headers = [@eth_header, @ip_header, @ospf_header]
			@headers += tmp_lsr
		end
		super(args)
		self
	end
end
