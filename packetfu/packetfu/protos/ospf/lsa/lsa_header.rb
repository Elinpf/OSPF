=begin
  This is LSA Header Packet
  All of LSA beginning the LSA Header
  20 Byte

  check LS age , LS seq and LS cksum Know who is new

  Struct:
    Int16 		:ospf_lsa_age		# LS Age
    Opt			:ospf_lsa_opt		# Options
    Int8		:ospf_lsa_lstype	# LS Type
    Octets		:ospf_lsa_lsid		# Link State ID
    Octets		:ospf_lsa_ar		# Advertising Routing
    Int32		:ospf_lsa_seq		# LS Sequence number
    Int16		:ospf_lsa_cksum		# LS checksum
    Int16		:ospf_lsa_len		# LS Length (include LSAHeader(20))

=end

class LSAHeader < Struct.new(
			:ospf_lsa_age, :ospf_lsa_opt, :ospf_lsa_lstype,
			:ospf_lsa_lsid, 
			:ospf_lsa_ar,
			:ospf_lsa_seq,
			:ospf_lsa_cksum, :ospf_lsa_len,
			:body)

	def self.lstype_class 
		{
			1 => 'LSARouter',
			2 => 'LSANetwork',
			3 => 'LSASummaryIP',
			4 => 'LSASummaryASBR',
			5 => 'LSAExternal',
			7 => 'LSANSSA'
		}
	end

	def self.lstype_class_factory
		{
			1 => 'lsa_router',
			2 => 'lsa_network',
			3 => 'lsa_summary_ip',
			4 => 'lsa_summary_asbr',
			5 => 'lsa_external',
			7 => 'lsa_nssa'
		}
	end

	def self.lstype 
		{
			1 => 'router',
			2 => 'network',
			3 => 'summaryIP',
			4 => 'smmaryASBR',
			5 => 'external',
			7 => 'nssa'
		}
	end

	include StructFu
	def initialize(args={})
		super(
			Int16.new(args['ospf_lsa_age'] || 0),
			Opt.new(args['ospf_lsa_opt'] || 0),
			Int8.new(args['ospf_lsa_lstype'] || 1),
			Octets.new.read(args['ospf_lsa_lsid'] || "\x00"*4),
			Octets.new.read(args['ospf_lsa_ar'] || "\x00"*4),
			Int32.new(args['ospf_lsa_seq'] || 0x80000000),
			Int16.new(args['ospf_lsa_cksum'] || 0x0000),
			Int16.new(args['ospf_lsa_len'] || 20),
			StructFu::String.new.read(args[:body]))
	end

	def to_s
		self.to_a.map {|x| x.to_s}.join
	end

	def read str
		force_binary str
		return self if str.nil?
		self['ospf_lsa_age'].read 	str[0,2]
		self['ospf_lsa_opt'].read 	str[2,1]
		self['ospf_lsa_lstype'].read 	str[3,1]
		self['ospf_lsa_lsid'].read 	str[4,4]
		self['ospf_lsa_ar'].read 	str[8,4]
		self['ospf_lsa_seq'].read 	str[12,4]
		self['ospf_lsa_cksum'].read 	str[16,2]
		self['ospf_lsa_len'].read 	str[18,2]
		self['body'].read 		str[20,str.size] if str.size > 20
		self
	end

	def ospf_calc_lsa_cksum(body)
		offset = 16

		lsa = body
		
		if lsa.size < offset
			raise RuntimeError, "LSA Packet too short (#{self.size} bytes)"
		end

		c0 = c1 = 0

		# set ospf_lsa_cksum to zero
		lsa[16, 2] = "\x00\x00"
		lsa[2, lsa.size].each_char do |char|
			c0 += char.ord
			c1 += c0
		end

		c0 %= 255
		c1 %= 255

		x = ((lsa.size - offset - 1) * c0 - c1) % 255

		x += 255 if (x <= 0)
		y = 510 - c0 - x
		y -= 255 if (y > 255)

		res = [x,y].pack("CC")
		self['ospf_lsa_cksum'].read res
		return res
	end

	def ospf_rand_lsa_cksum
		self['ospf_lsa_cksum'].read(rand(0xffff))
		ospf_lsa_cksum
	end

=begin
	def ospf_calc_lsa_len
		self.size
	end
=end

	def ospf_lsa_seq_inc
		self['ospf_lsa_seq'].read(ospf_lsa_seq + 1)
		return ospf_lsa_seq
	end

	def ospf_lsa_age; 	self['ospf_lsa_age'].to_i; end
	def ospf_lsa_age=(v); 	typecast v; end

	def ospf_lsa_opt;	self['ospf_lsa_opt'].to_i; end
	def ospf_lsa_opt=(v); 	typecast v; end
	def ospf_lsa_opt_readable
		self['ospf_lsa_opt'].readable
	end
	
	# DN, O, DC, L, NP, MC, E, MT 
	def ospf_lsa_opt_set(*args)
		self['ospf_lsa_opt'].opt_set(args)
	end

	# DN, O, DC, L, NP, MC, E, MT 
	def ospf_lsa_opt_unset(*args)
		self['ospf_lsa_opt'].opt_unset(args)
	end

	def ospf_lsa_opt_set?(flag)
		self['ospf_lsa_opt'].has_set?(flag)
	end

	def ospf_lsa_lstype; 	self['ospf_lsa_lstype'].to_i; end
	def ospf_lsa_lstype=(v);	typecast v; end

	def ospf_lsa_lsid;	self['ospf_lsa_lsid'].to_i; end
	def ospf_lsa_lsid=(v); 	typecast v; end
	
	def ospf_lsa_ar;	self['ospf_lsa_ar'].to_i; end
	def ospf_lsa_ar=(v);	typecast v; end

	def ospf_lsa_seq;	self['ospf_lsa_seq'].to_i; end
	def ospf_lsa_seq=(v);	typecast v; end
	def ospf_lsa_seq_readable
		"0x%08x" % ospf_lsa_seq
	end

	def ospf_lsa_cksum; 	self['ospf_lsa_cksum'].to_i; end
	def ospf_lsa_cksum=(v);	typecast v; end
	def ospf_lsa_cksum_str
		ck = ospf_lsa_cksum
		[ck].pack("n")
	end
	def ospf_lsa_cksum_readable
		"0x%04x" % ospf_lsa_cksum
	end

	def ospf_lsa_len;	self['ospf_lsa_len'].to_i; end
	def ospf_lsa_len=(v);	typecast v; end

	def ospf_lsa_lsid_str;  self['ospf_lsa_lsid'].to_s; end
	def ospf_lsa_lsid_quad;	self['ospf_lsa_lsid'].to_x; end
	def ospf_lsa_lsid_quad=(v)
		self['ospf_lsa_lsid'].read_quad v
	end

	def ospf_lsa_ar_str; 	self['ospf_lsa_ar'].to_s; end
	def ospf_lsa_ar_quad;	self['ospf_lsa_ar'].to_x; end
	def ospf_lsa_ar_quad=(v)
		self['ospf_lsa_ar'].read_quad v
	end

	alias :ospf_lsa_lsid_readable :ospf_lsa_lsid_quad
	alias :ospf_lsa_ar_readable   :ospf_lsa_ar_quad
end


include PacketFu
class LSAHeaderPacket < Packet
	attr_accessor :lsa_header
	# method : ospf_inject_lsa pkt
	include PacketFu::Inject
	def initialize(args={})	
		@lsa_header = Factory.create_lsa_header(args)

		@headers = [@lsa_header]
		super
		@lsa_menu = Factory.create_menu(self)
		self
	end

	def self.can_parse? str
		str.size >= 20 ? true : false
	end

	def read(str=nil, args={})
		raise "Can't parse #{self.class}" unless LSAHeaderPacket.can_parse? str
		@lsa_header.read str
		super(args)
		@lsa_menu = Factory.create_menu(self)
		self
	end

	def menu
		@lsa_menu
	end

end
