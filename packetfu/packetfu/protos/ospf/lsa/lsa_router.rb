=begin
  This is Router-LSA Packet
  4 Byte

  LSAHeader
--------------
  Router-LSA
--------------
  LSAOpt		:ospf_lsa_opt		# V, E, B flags
  Void			:ospf_lsa_void		# void
  Int16			:ospf_lsa_links		# Number of Links
  String		:body			# Each interface must description in one LSA


LSALink(:ospf_lsa_link)
12Bype
--------------
  Octets 		:ospf_lsa_lkid		# Link ID
  Octets		:ospf_lsa_lkdata	# Link Data
  Int8			:ospf_lsa_lktype	# Link Type
  Int8 			:ospf_lsa_tos		# Number of TOS metrices
  Int16			:ospf_lsa_metric	# TOS 0 metric
  String		:body			# If have other LSA Link

=end

class LSALink < Struct.new(
		:ospf_lsa_lkid, :ospf_lsa_lkdata,
		:ospf_lsa_lktype, :ospf_lsa_tos, :ospf_lsa_metric,
		:body)
	include StructFu

	@@lsa_link_type = {
		1 => 'p2p',
		2 => 'transit',
		3 => 'stub',
		4 => 'virtual'
	}


	def initialize(args={})
		super(
			Octets.new.read(args['ospf_lsa_lkid'] || "\x00"*4),
			Octets.new.read(args['ospf_lsa_lkdata'] || "\x00"*4),
			Int8.new(args['ospf_lsa_lktype'] || 3),
			Int8.new(args['ospf_lsa_tos'] || 0),
			Int16.new(args['ospf_lsa_metric'] || 1),
			StructFu::String.new.read(args['body']))
		@menu_item = Factory.create_menu_item(self)
	end

	def to_s
		self.to_a.map {|x| x.to_s}.join
	end

	def self.can_parse? str
		str.size % 12 == 0 ? true : false
	end

	def read str
		force_binary str
		return self if str.nil?
		self['ospf_lsa_lkid'].read str[0,4]
		self['ospf_lsa_lkdata'].read str[4,4]
		self['ospf_lsa_lktype'].read str[8,1]
		self['ospf_lsa_tos'].read str[9,1]
		self['ospf_lsa_metric'].read str[10,2]
		self['body'].read str[12,str.size] if str.size > 12
		@menu_item = Factory.create_menu_item(self)
		self
	end
			
	def menu_item
		@menu_item
	end

	def ospf_lsa_lkid; 	self['ospf_lsa_lkid'].to_i; end
	def ospf_lsa_lkid=(v)
		case v
		when Octets
			self['ospf_lsa_lkid'] = v
		else
			typecast v
		end
	end

	def ospf_lsa_lkdata;	self['ospf_lsa_lkdata'].to_i; end
	def ospf_lsa_lkdata=(v)
		case v
		when Octets
			self['ospf_lsa_lkdata'] = v
		else
			typecast v
		end
	end

	def ospf_lsa_lktype; 	self['ospf_lsa_lktype'].to_i; end
	def ospf_lsa_lktype=(v);	typecast v; end

	def ospf_lsa_tos;	self['ospf_lsa_tos'].to_i; end
	def ospf_lsa_tos=(v);	typecast v; end

	def ospf_lsa_metric; 	self['ospf_lsa_metric'].to_i; end
	def ospf_lsa_metric=(v);	typecast v; end

	def ospf_lsa_lkid_str;	self['ospf_lsa_lkid'].to_s; end
	def ospf_lsa_lkid_quad;	self['ospf_lsa_lkid'].to_x; end
	def ospf_lsa_lkid_quad=(v); self['ospf_lsa_lkid'].read_quad v; end

	def ospf_lsa_lkdata_str;	self['ospf_lsa_lkdata'].to_s; end
	def ospf_lsa_lkdata_quad;	self['ospf_lsa_lkdata'].to_x; end
	def ospf_lsa_lkdata_quad=(v); self['ospf_lsa_lkdata'].read_quad v; end

	def ospf_lsa_lktype_readable
		@@lsa_link_type[ospf_lsa_lktype]
	end

	alias :ospf_lsa_lkid_readable 	:ospf_lsa_lkid_quad
	alias :ospf_lsa_lkdata_readable	:ospf_lsa_lkdata_quad
end


class LSARouter < Struct.new(
			:ospf_lsa_opt, :ospf_lsa_void,
			:ospf_lsa_links,
			:body)
	include StructFu

	def initialize(args={})
		super(
			LSAOpt.new(args['ospf_lsa_opt'] || 0),
			Int8.new(args['ospf_lsa_void'] || 0),
			Int16.new(args['ospf_lsa_links'] || 0),
			StructFu::String.new.read(args[:body]))
	end

	def to_s
		self.to_a.map {|x| x.to_s}.join
	end


	def read str
		force_binary str
		return self if str.nil?
		self['ospf_lsa_opt'].read str[0,1]
		self['ospf_lsa_links'].read str[2,2]
		self['body'].read str[4,str.size] if str.size > 4
		self
	end

	def ospf_lsa_opt; 	self['ospf_lsa_opt'].to_i; end
	def ospf_lsa_opt=(v); 	typecast v; end
	def ospf_lsa_opt_readable
		self['ospf_lsa_opt'].readable
	end

	def ospf_lsa_void;	self['ospf_lsa_void'].to_i; end
	def ospf_lsa_void=(v);	typecast v; end
	
	# V B E
	def ospf_lsa_opt_set(*args)
		self['ospf_lsa_opt'].opt_set(args)
	end
	
	# V B E
	def ospf_lsa_opt_unset(*args)
		self['ospf_lsa_opt'].opt_unset(args)
	end

	def ospf_lsa_opt_set?(flag)
		self['ospf_lsa_opt'].has_set?(flag)
	end
	
	def ospf_lsa_links;	self['ospf_lsa_links'].to_i; end
	def ospf_lsa_links=(v);	typecast v; end

	def ospf_calc_lsa_links
	end

=begin
 	# This method is get LSALink
	def ospf_lsa_link; 	self['ospf_lsa_link'].to_s; end

	# This methods can be inject lsa_ link to ArrayFu
	# I Dont know why can't set String for case
	def ospf_inject_lsa_link(link)
		case link
		when Array
			self['ospf_lsa_link'].read link
		when LSALink
			self['ospf_lsa_link'].push link
		else
			self['ospf_lsa_link'].push(LSALink.new.read(link))
		end
	end

	def ospf_remove_lsa_link
	end

	# return the LSALink Class
	def ospf_index_lsa_link i
		self['ospf_lsa_link'][i]
	end

	def ospf_calc_lsa_links
		num = self['ospf_lsa_link'].size
		self.ospf_lsa_links = num
		return num
	end
=end
end


#	
# LSARouterPacket
# LSARouterPacket.new(:lsa_link => [LSALink.new, LSALink.new])
#
include PacketFu
class LSARouterPacket < Packet
	attr_accessor :lsa_header, :lsa_router
	def initialize(args={})
		@lsa_router = Factory.create_lsa_router(args)
		@lsa_header = Factory.create_lsa_header(args)
		@lsa_header.body = @lsa_router

		@headers = [@lsa_header, @lsa_router]

		super
		@lsa_menu = Factory.create_menu(self)
		self
	end

=begin
	def lsa_inject_link link
		header_links = []
		case link
		when Array
			link.each do |l|
				if l.kind_of? LSALink
					header_links << l
				elsif LSALink.can_parse? l
					l = LSALink.new.read l
					header_links << l
				else
					raise ArgumentError, "Can't parse lsa_link"
				end
			end
		when LSALink
			header_links << link
		when String
			if LSALink.can_parse? link
				header_links << LSALink.new.read(link)
			else
				raise ArgumentError, "Can't parse lsa_link"
			end
		else
				raise ArgumentError, "Input lsa_link must be Array, LSALink class or String"
		end
		_lsa_recalc_headers header_links
	end

	def _lsa_recalc_headers header_links
		if not header_links.empty?
			header_links.each_with_index do |e, i|
				if header_links[i+1] != nil
					e.body = header_links[i+1]
				end
				@headers.push e
			end
			@lsa_router.body = header_links[0]
		end
		return @headers
	end

	def ospf_get_lsa_link index
		@headers[2 + index]
	end
=end

	# :NOTE: this str just LSA Packet
	def self.can_parse? str
		return false unless LSAHeaderPacket.can_parse? str
		return false unless str[3,1] == "\x01"
		return false unless str.size >= 20 + 4
		link_num = str[22,2].unpack("n").first
		if link_num  > 0
			# return false unless str.size >= 24 + (link_num * 12)
			return (str.size - 24) % 12 == 0 ? true : false
		end
		true
	end

	def read(str=nil,args={})
		raise "Can't parse #{self.class}" unless LSARouterPacket.can_parse? str
		@lsa_header.read str
		@lsa_router.read str[20, 4]

		@lsa_header.body = @lea_router
		link_num =  @lsa_router.ospf_lsa_links 
		menu = Factory.create_menu(self)
		if link_num > 0
			offset = 24
			link_num.times do |t|
				lk = Factory.create_lsa_link.read str[offset, 12]
				menu.add lk.menu_item
				offset += 12
			end
		end
		@lsa_menu = menu
		super(args)
		self
	end

	def menu
		@lsa_menu
	end

	def ospf_calc_lsa_links
		self.ospf_lsa_links = self.menu.size
	end
end

	
	
