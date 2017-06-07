=begin
 This is OSPF Header Packet
 24 Byte
 +-----------+
 Int8 		:ospf_ver	Default: 2
 Int8 		:ospf_type	Default:
 			 1 => Hello Packet
			 2 => Database Description
			 3 => Link State Request
			 4 => Link State Update
			 5 => Link State Ack
 Int16 		:ospf_len	Default: nil
 RouteID 	:ospf_rid 		# Route ID
 AreaID		:ospf_aid		# Area ID
 Int16  	:ospf_cksum		# Checksum
 Int16  	:ospf_autype		# Authentication Type
 Int64  	:ospf_auth    		# Authentication
 String		:body			# Next Type of ospf packet

 :Note:
 	All of read are use /x00/x00 
	read_quad is 192.168.18.1
	read_i is area 1 => /x00/x00/x00/x01
=end

require "ipaddr"

class Octets < Struct.new( :o1, :o2, :o3, :o4)
	include StructFu
	def initialize(args={})
		super(
			Int8.new(args['o1']),
			Int8.new(args['o2']),
			Int8.new(args['o3']),
			Int8.new(args['o4']))
	end

	def to_s
		self.to_a.map {|o| o.to_s}.join
	end

	def to_x
		ip_str = self.to_a.map {|o| o.to_i.to_s}.join('.')
		IPAddr.new(ip_str).to_s
	end

	def read str
		raise ArgumentError, "Input String" unless str.kind_of? ::String or \
			str.kind_of? NilClass
		force_binary(str)
		return self if str.nil?
		self['o1'].read str[0,1]
		self['o2'].read str[1,1]
		self['o3'].read str[2,1]
		self['o4'].read str[3,1]
		self
	end

	def read_quad str
		raise ArgumentError, "Input String" unless str.kind_of? ::String or \
			str.kind_of? NilClass
		read([IPAddr.new(str).to_i].pack('N'))
	end

	def to_i
		addr = self.to_a.map {|x| x.to_i.to_s}.join('.')
		IPAddr.new(addr).to_i
	end
end

class ID < Octets; end
class RouteID < ID; end

class AreaID < ID
	# read like Area 0
	def read_i int
		raise ArgumentError, "Input Fixnum" unless ::Fixnum === str
		read([int].pack('N'))
	end
		
	def to_i
		res = 0
		res += self['o1'].to_i << 24
		res += self['o2'].to_i << 16
		res += self['o3'].to_i << 8
		res += self['o4'].to_i
		res 
	end
end

class Int64 < Struct.new(:low, :high)
	include StructFu
	def initialize(args={})
		super(
			Int32.new(args['low'] || ("\x00" * 4)),
			Int32.new(args['high'] || ("\x00" * 4))
		)
	end
		 
	def to_s
		self['low'].to_s + self['high'].to_s
	end

	def read str
		force_binary str
		self['low'].read str[0,4]
		self['high'].read str[4,4]
		self
	end

	def to_i
		i = self['low'].to_i << 32
		i += self['high'].to_i
	end
end
		

class OSPFHeader < Struct.new(
		:ospf_ver, :ospf_type, :ospf_len,
		:ospf_rid,
		:ospf_aid,
		:ospf_cksum, :ospf_autype,
		:ospf_auth,
		:body)

	@@ospf_type = {
		1 => "Hello",
		2 => "DBDesc",
		3 => "LSReq",
		4 => "LSUpd",
		5 => "LSAck"}

	include StructFu
	def initialize(args={})
		super(
			Int8.new(args['ospf_ver'] || 2),
			Int8.new(args['ospf_type'] || 1),
			Int16.new(args['ospf_len'] || 0),
			RouteID.new.read(args['ospf_rid'] || "\x00\x00\x00\x00"),
			AreaID.new.read(args['ospf_aid'] || "\x00\x00\x00\x00"),
			Int16.new(args['ospf_cksum'] || 0),
			Int16.new(args['ospf_autype'] || 0),
			Int64.new.read(args['ospf_auth'] || "\x00" * 8),
			StructFu::String.new.read(args[:body]))
	end

	def to_s
		self.to_a.map {|x| x.to_s}.join
	end

	def read str
		force_binary str
		return self if str.nil?
		self['ospf_ver'].read str[0,1]
		self['ospf_type'].read str[1,1]
		self['ospf_len'].read str[2,2]
		self['ospf_rid'].read str[4,4]
		self['ospf_aid'].read str[8,4]
		self['ospf_cksum'].read str[12,2]
		self['ospf_autype'].read str[14,2]
		self['ospf_auth'].read str[16,8]
		self['body'].read str[24,str.size] if str.size > 24
		self
	end
		

	def ospf_ver; self['ospf_ver'].to_i; end
	def ospf_ver=(v); typecast v; end

	def ospf_type; self['ospf_type'].to_i; end
	def ospf_type=(v); typecast v; end

	def ospf_len; self['ospf_len'].to_i; end
	def ospf_len=(v); typecast v; end

	def ospf_rid; self['ospf_rid'].to_i; end
	def ospf_rid=(v)
		case v
		when RouteID
			self['ospf_rid'] = v
		else
			typecast v
		end
	end

	def ospf_aid; self['ospf_aid'].to_i; end
	def ospf_aid=(v)
		case v
		when AreaID
			self['ospf_aid'] = v
		else
			typecast v
		end
	end

	def ospf_cksum; self['ospf_cksum'].to_i; end
	def ospf_cksum=(v); typecast v; end
	def ospf_cksum_readable
		"0x%04x" % ospf_cksum
	end

	def ospf_autype; self['ospf_autype'].to_i; end
	def ospf_autype=(v); typecast v; end

	def ospf_auth; self['ospf_auth'].to_i; end
	def ospf_auth=(v); typecast v; end

	# This cksum is IP checksum
	def ospf_calc_cksum
		ck = (self.ospf_ver << 8) + self.ospf_type
		ck += 	self.ospf_len
		ck += (self.ospf_rid >> 16)
		ck += (self.ospf_rid & 0xffff)
		ck += (self.ospf_aid >> 16)
		ck += (self.ospf_aid & 0xffff)
		ck += self.ospf_autype
		## calc body
		str = self.body.to_s
		if not str.empty?	
			if str.size % 2 != 0
				str << "\x00"
			end
			offset = 0
			ck_str = 0
			num = str.size / 2
			num.times do |t|
				ck_str += str[offset, 2].unpack("n").first
				offset += 2
			end
		end
		ck += ck_str
		ck = ck % 0xffff
		ck = 0xffff - ck
		ck == 0 ? 0xffff : ck
	end

	def ospf_calc_len
		#self.to_s.size 
		24 + self['body'].to_s.size
	end

	def ospf_recalc(arg = :all)
		case arg
		when :all
			self.ospf_len = ospf_calc_len
			self.ospf_cksum = ospf_calc_cksum
		when :ospf_cksum
			self.ospf_cksum = ospf_calc_cksum
		when :ospf_len
			self.ospf_len = ospf_calc_len
		else
			raise ArgumentError, "No such filed `#{arg}'"
		end
	end

	def ospf_rid_str
		self['ospf_rid'].to_s
	end

	def ospf_rid_quad
		self['ospf_rid'].to_x
	end

	def ospf_rid_quad=(v)
		self['ospf_rid'].read_quad v
	end

	def ospf_aid_quad
		self['ospf_aid'].to_x
	end

	def ospf_aid_str
		self['ospf_aid'].to_s
	end

	def ospf_aid_quad=(v)
		self['ospf_aid'].read_quad v
	end

	def ospf_aid_i=(v)
		self['ospf_aid'].read_i v.to_i
	end

	def ospf_autype_def
		self['ospf_autype'].read("\x00\x00")
	end

	def ospf_auth_def
		self['ospf_auth'].read("\x00" * 8)
	end

	alias :ospf_aid_readable :ospf_aid_quad
	alias :ospf_rid_readable :ospf_rid_quad
end

include PacketFu
class OSPFHeaderPacket < Packet
	attr_accessor :eth_header, :ip_header, :ospf_header
	def initialize(args={})
		@eth_header = Factory.create_eth_header(args)
		@ip_header  = Factory.create_ip_header(args)
		@ospf_header = Factory.create_ospf_header(args)

		@ip_header.body = @ospf_header
		@eth_header.body = @ip_header

		@headers = [@eth_header, @ip_header, @ospf_header]
		super
	end

	def self.can_parse? str
		return false unless str.size >= 58
		return false unless EthPacket.can_parse? str
		return false unless IPPacket.can_parse? str
		return false unless str[34, 1] == "\x02" # version 2
		true
	end

	def read(str=nil, args={})
		raise "Can't parse `#{str}'" unless self.class.can_parse? str
		@eth_header.read str
		@ip_header.read str[14, str.size]
		@ospf_header.read  str[14+20, str.size]

		@ip_header.body = @ospf_header
		@eth_header.body = @ip_header
		super(args)
		self
	end

end # class
