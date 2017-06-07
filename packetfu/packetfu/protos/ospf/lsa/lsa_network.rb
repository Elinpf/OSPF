=begin
  This is Network-LSA Packet
  8 Byte

LSAHeader
---------------
LSANetwork
---------------
 Octets		:ospf_lsa_netmask	# Network Mask
 Octets		:ospf_lsa_attrouter	# Attached Router
 String		:body

What is Attrouter Class:
A single class to inject ospf_lsa_attrouter
=end

class Attrouter < Struct.new(
		:ospf_lsa_attrouter, :body)
	include StructFu
	def initialize(args={})
		super(
			Octets.new.read(args['ospf_lsa_attrouter'] || "\x00"*4),
			StructFu::String.new.read(args[:body]))
		@menu_item = Factory.create_menu_item(self)
	end

	def to_s
		self.to_a.map {|x| x.to_s}.join
	end

	def read str
		force_binary str
		return self if str.nil?
		self['ospf_lsa_attrouter'].read str[0,4]
		self['body'].read str[4,str.size] if str.size > 4
		@menu_item = Factory.create_menu_item(self)
		self
	end

	def menu_item
		@menu_item
	end

	def ospf_lsa_attrouter; 	self['ospf_lsa_attrouter'].to_i; end
	def ospf_lsa_attrouter_str;	self['ospf_lsa_attrouter'].to_s; end
	def ospf_lsa_attrouter_quad;	self['ospf_lsa_attrouter'].to_x; end
	def ospf_lsa_attrouter=(v)
		case v
		when Octets
			self['ospf_lsa_attrouter'] = v
		else
				typecast v
		end
	end

	def ospf_lsa_attrouter_quad=(v); 	self['ospf_lsa_attrouter'].read_quad v; end

	alias :ospf_lsa_attrouter_readable :ospf_lsa_attrouter_quad
end


class LSANetwork < Struct.new(
		:ospf_lsa_netmask, :ospf_lsa_attrouter,
		:body)
	include StructFu
	def initialize(args={})
		super(
			Octets.new.read(args['ospf_lsa_netmask'] || "\x00"*4),
			Octets.new.read(args['ospf_lsa_attrouter'] || "\x00"*4),
			StructFu::String.new.read(args[:body]))
	end

	def to_s
		self.to_a.map {|x| x.to_s}.join
	end

	def read str
		force_binary str
		return self if str.nil?
		self['ospf_lsa_netmask'].read str[0,4]
		self['ospf_lsa_netmask'].read str[4,4]
		self['body'].read str[8, str.size] if str.size > 8
		self
	end

	def ospf_lsa_netmask; 		self['ospf_lsa_netmask'].to_i; end
	def ospf_lsa_netmask_str;	self['ospf_lsa_netmask'].to_s; end
	def ospf_lsa_netmask_quad;	self['ospf_lsa_netmask'].to_x; end
	def ospf_lsa_netmask=(v)
		case v
		when Octets
			self['ospf_lsa_netmask'] = v
		else
				typecast v
		end
	end

	def ospf_lsa_netmask_quad=(v); 	self['ospf_lsa_netmask'].read_quad v; end


	def ospf_lsa_attrouter; 	self['ospf_lsa_attrouter'].to_i; end
	def ospf_lsa_attrouter_str;	self['ospf_lsa_attrouter'].to_s; end
	def ospf_lsa_attrouter_quad;	self['ospf_lsa_attrouter'].to_x; end
	def ospf_lsa_attrouter=(v)
		case v
		when Octets
			self['ospf_lsa_attrouter'] = v
		else
				typecast v
		end
	end

	def ospf_lsa_attrouter_quad=(v); 	self['ospf_lsa_attrouter'].read_quad v; end

	alias :ospf_lsa_attrouter_readable :ospf_lsa_attrouter_quad
	alias :ospf_lsa_netmask_readable   :ospf_lsa_netmask_quad
end



=begin
class LSANetwork < Struct.new(:ospf_lsa_netrouter)
	include StructFu
	def initialize(args={})
		super(ArrayFu.new.read(args['ospf_lsa_netrouter'] || nil))
	end

	def to_s
		self.to_a.map {|x| x.to_s}.join
	end

	def read str
		force_binary str
		return self if str.nil?
		num = str.size
		if num % 8 == 0
			nets = []
			(num / 8).times do |t|
				nets << LSANetRouter.new.read(str[8*t, 8*(t+1)])
			end
			self['ospf_lsa_netrouter'].read nets
		end
		self
	end

	def ospf_inject_lsa_netrouter nets
		case nets
		when Array
			self['ospf_lsa_netrouter'].read nets
		when LSANetRouter
			self['ospf_lsa_netrouter'].push nets
		else
			self['ospf_lsa_netrouter'].push(LSANetRouter.new.read(nets))
		end
	end

	def ospf_calc_lsa_netrouter
		nets = self['ospf_lsa_netrouter']
		if nets.size == 1 and nets.first.nil?
			return 0
		else
			return nets.size
		end
	end

	def ospf_index_lsa_netrouter i
		self['ospf_lsa_netrouter'][i]
	end
		
end

	
=end

include PacketFu
class LSANetworkPacket < Packet
	attr_accessor :lsa_header, :lsa_network, :lsa_menu
	def initialize(args={})
		lsa_type = {'ospf_lsa_lstype' => 2}
		args.merge!(lsa_type)
		@lsa_header  = Factory.create_lsa_header(args)
		@lsa_network = Factory.create_lsa_network(args)
		@lsa_header.body = @lsa_network

		@headers = [@lsa_header, @lsa_network]

		super
		@lsa_menu = Factory.create_menu(self)
		self
	end

	def self.can_parse? str
		return false unless LSAHeaderPacket.can_parse? str
		return false unless str[3,1] == "\x02"
		return false unless str.size >= 28
		len = str.size - 28
		if len > 0
			return len % 4 == 0 ? true : false
		end
		true
	end

	def read(str=nil, args={})
		raise "Can't parse #{self.class}" unless self.class.can_parse? str
		@lsa_header.read str[0, 20]
		@lsa_network.read str[20, 8]

		@lsa_header.body = @lsa_network
		menu = Factory.create_menu(self)
		if str.size > 28
			# attrouter number , exception the first attrouter
			num = (str.size - 28) / 4
			offset = 28
			num.times do |t|
				ar = Factory.create_lsa_attrouter.read str[offset, 4]
				menu.add(ar.menu_item)
				offset += 4
			end
		end
		@lsa_menu = menu
		super(args)
		self
	end

	# return Menu Class
	def menu
		@lsa_menu
	end
end
