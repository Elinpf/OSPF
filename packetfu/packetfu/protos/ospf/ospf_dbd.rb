=begin
  This is DB Description 
  Base 8Byte (without ospf_lsa_headers)

  Int16		:ospf_mtu		# Interface MTU 	+Deafult:1500
  Opt		:ospf_opt		# Options 
  DBOpt		:ospf_dbd_opt		# DB Description Option
  Int32		:ospf_seq		# DD Sequence number
  Menu		:ospf_lsa_headers	# Payload LSA headers
  String	:body		

=end

class OSPFDBD < Struct.new(
		:ospf_mtu, :ospf_opt, :ospf_dbd_opt,
		:ospf_seq, :ospf_lsa_headers, :body)
	include StructFu
	def initialize(args={})
		super(
			Int16.new(args['ospf_mtu'] || 1500),
			Opt.new(args['ospf_opt'] || 0),
			DBDOpt.new(args['ospf_dbd_opt'] || 0),
			Int32.new(args['ospf_seq'] || 0),
			# ospf_lsa_headers
			Menu.new(""),
			StructFu::String.new.read(args[:body]))
	end

	def to_s
		self.to_a.map {|x| x.to_s}.join
	end

	# Opt I bit is not set and M bit set
	def read str
		force_binary str
		return self if str.nil?
		self['ospf_mtu'].read str[0,2]
		self['ospf_opt'].read str[2,1]
		self['ospf_dbd_opt'].read str[3,1]
		self['ospf_seq'].read str[4,4]
		self.ospf_clear_lsa
		if str.size > 8 and (str.size - 8) % 20 == 0
			num = (str.size - 8) / 20
			offset = 8
			num.times do |t|
				tmp = Factory.create_lsa_header_packet.read(
						str[offset, 20])
				self.ospf_inject_lsa tmp.menu
				offset += 20
			end
		end
		self


=begin
		# problem
		if !self['ospf_dbd_opt'].has_set?("i") and self['ospf_dbd_opt'].has_set "m"
			lsa_header_num = (str.size - 8) / 20
			lsa_header_num.times do |t|
				if t == 0
					self['ospf_lsa_headers'] = \
						Factory.create_lsa_header_packet
				else
					self['ospf_lsa_headers'].ospf_lsa_inject \
						Factory.create_lsa_header_packet
				end
			end
		end
		if str.size > 4 + (lsa_header_num * 20)
			self['body'].read str[4+(lsa_header_num*20), str.size]
		end
		self
=end
	end


	def ospf_mtu; 	self['ospf_mtu'].to_i; end
	def ospf_mtu=(v);	typecast v;    end

	def ospf_opt;	self['ospf_opt'].to_i; end
	def ospf_opt=(v)
		case v
		when Opt
			self['ospf_opt'] = v
		else
			typecase v
		end
	end

	def ospf_dbd_opt;self['ospf_dbd_opt'].to_i; end
	def ospf_dbd_opt=(v)
		case v
		when DBDOpt
			self['ospf_dbd_opt'] = v
		else
			typecase v
		end
	end

	def ospf_seq;	self['ospf_seq'].to_i; end
	def ospf_seq=(v); 	typecast v; end
	def ospf_seq_readable
		"0x%08x" % self.ospf_seq
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
	# R, I, M, MS
	def ospf_dbd_opt_set(*opts)
		self['ospf_dbd_opt'].opt_set(opts)
	end

	# R, I, M, MS
	def ospf_dbd_opt=(v)
		raise ArgumentError unless DBDOpt === v
		self['ospf_dbd_opt'] = v
	end

	def ospf_dbd_opt_unset(*opts)
		self['ospf_dbd_opt'].opt_unset(opts)
	end

	def ospf_dbd_opt_set?(flag)
		self['ospf_dbd_opt'].has_set?(flag)
	end

	def ospf_dbd_opt_readable
		self['ospf_dbd_opt'].readable
	end

	def ospf_dbd_opt_class
		self['ospf_dbd_opt']
	end

	def ospf_lsa_headers; self['ospf_lsa_headers'].to_s; end
	def ospf_lsa_headers_p; self['ospf_lsa_headers'].to_pkt; end
	def ospf_lsa_headers_class
		self['ospf_lsa_headers']
	end
	def ospf_lsa_headers=(menu)
		raise "Must input Menu Class" unless Menu === menu
		self['ospf_lsa_headers'] = menu
	end
	# alias
	def ospf_lsa_p; self.ospf_lsa_headers_p; end

	# lsa headers
	def ospf_inject_lsa menu
		raise "Must input Menu Class" unless Menu === menu
		self['ospf_lsa_headers'].add menu
	end

	def ospf_clear_lsa
		self['ospf_lsa_headers'].clear
	end

	def ospf_lsa_headers_readable
		res = ""
		num = self['ospf_lsa_headers'].size
		if num == 0
			res = "."
		else
			num.times do |t|
				res << "!"
			end
		end
		res
	end
			


=begin
	def ospf_inject_lsa_packet(pkt=nil, args={})
		_super_ = LSAInjectPacket.new
		tmp = _super_.ospf_inject_lsa_packet(
				self['ospf_lsa_headers'], pkt, "header", args)
		self['ospf_lsa_headers'] = tmp
	end

	def ospf_lsa_headers_readable
		if self['ospf_lsa_headers'].nil?
			return "."
		else
			res = ""
			self['ospf_lsa_headers'].headers.size.times do |t|
				res << "!"
			end
		end
		return res
	end
=end
end

include PacketFu
class OSPFDBDPacket < Packet
	attr_accessor :eth_header, :ip_header, :ospf_header, :ospf_dbd
	def initialize(args={})
		pro_config = {
			:ip_proto => 89,
			'ospf_type' => 2}
		args.merge!(pro_config)
		@eth_header = Factory.create_eth_header(args)
		@ip_header  = Factory.create_ip_header(args)
		@ospf_header = Factory.create_ospf_header(args)
		@ospf_dbd   = Factory.create_ospf_dbd(args)

		@ospf_header.body = @ospf_dbd
		@ip_header.body = @ospf_header
		@eth_header.body = @ip_header

		@headers = [@eth_header, @ip_header, @ospf_header, @ospf_dbd]
		super
		self
	end

	def self.can_parse? str
		return false unless EthPacket.can_parse? str
		return false unless IPPacket.can_parse? str
		return false unless OSPFHeaderPacket.can_parse? str
		return false unless str.size >= 66
		true
	end

	def read(str=nil, args={})
                raise "Can't parse #{self.class}" unless self.class.can_parse? str
		@eth_header.read str
		@ip_header.read  str[14,str.size]
		@ospf_header.read str[14+20, str.size]
		@ospf_dbd.read str[34+24, str.size]

		super(args)
		self
	end
end
