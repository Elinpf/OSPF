=begin
  This Class Only Used in ospf_lsu.rb
  @payloads : each of MenuItem
  @payload  : in MenuItem the true packet class

  How to Use
  header = Menu.new(Factory.create_lsa_header_packet)
  router_1 = MenuItem.new(Factory.create_lsa_router)
  router_2 = MenuItem.new(Factory.create_lsa_router)
  header.add(router_1)
  header.add(router_2)

  header.to_pkt
  p header
=end
class ComboError < StandardError
	def to_s
		"Must Override This Method"
	end
end

class Combo
	# contorl
	def add pkt; raise ComboError.new; end
	def <<  pkt; raise ComboError.new; end
	def remove; raise ComboError.new; end  
	def clear; raise ComboError.new; end
	def get_child int; raise ComboError.new; end
	def get_range int; raise ComboError.new; end

	# method
	def to_s; raise ComboError.new; end
	def read(str); raise ComboError.new; end
	def size; raise ComboError.new; end
	def body=(str); raise ComboError.new; end
	def inspect; raise ComboError.new; end
	def to_pkt; raise ComboError.new; end

	def slice; raise ComboError.new; end
	def slice!; raise ComboError.new; end

	def ospf_calc_lsa_links; raise ComboError.new; end
	def ospf_calc_lsa_len; raise ComboError.new; end
	def ospf_calc_lsa_cksum; raise ComboError.new; end
	def ospf_recalc_lsa; raise ComboError.new; end
end

class Menu < Combo
	attr_accessor :header
	def initialize(header="")
		@header = header
		@payloads = []
	end

	def add menu
		begin
			raise "Must MenuItem Class" unless menu.kind_of? Combo
		rescue
			raise "Must MenuItem Class"
		end
		@payloads << menu
	end

	def << menu
		self.add menu
	end

	def remove index
		@payloads.delete_at index
	end

	def clear
		@payloads = []
	end

	def get_child index
		@payloads[index]
	end

	def get_range int
		num = self.size
		res = []
		if num > int
			int.times do |t|
				res << get_child(t)
			end
		else
			num.times do |t|
				res << get_child(t)
			end
		end
		res
	end


	# This method is use for get each lsa
	def each &block
		if @header == ""
			@payloads.each do |p|
				p &blcok
			end
			return
		end
		@payloads.each do |p|
			yield p.payload
		end
	end

	def to_s
		res = []
		res << @header.to_s 
		@payloads.each do |p|
			res << p.to_s
		end
		res.join
	end

	def read str
	end

	def inspect
		"#<Menu Class: include #{@header.class}>"
	end

# This method just a inspect 
# This method have to type
# One type is: if it is all Menu, zhe @header must be empty and collect each other Menu
# Second type is: if the @header not empty, means that has Item and return inspect
	def to_pkt
		if @header == ""
			@payloads.each do |p|
				p.to_pkt
			end
			return 
		elsif
			num = @payloads.size
			tmp = []
			tmp_header = @header.clone
			(0...num).to_a.reverse.each do |i|
				if i == num - 1
					tmp[i] = @payloads[i].to_pkt
					next
				else
					@payloads[i].body = @payloads[i+1].to_pkt
					tmp[i] = @payloads[i].to_pkt
				end
			end

			if @header.respond_to? :headers
				tmp_header.payload = tmp[0]
				tmp_h = tmp_header.headers
				tmp_header.headers += tmp
				
				p tmp_header
				return
			else
				raise "The Fisrt class Must be Packet"
			end
		end
	end

	def size
		@payloads.size
	end

	def body=(v)
		@header.body = v
	end

	def ospf_calc_lsa_len
		# if is allMenu
		if @header == ""
			@payloads.each do |h|
				if h.header.class.to_s.match(/^LSA.*Packet$/)
					h.ospf_calc_lsa_len
				else
					next
				end
			end
			return
		end

		# if is Header Menu
		len = self.to_s.size
		@header.ospf_lsa_len = len
	end

 	# slice the LSA Header
	def slice
		# if is allMenu
		if @header == ""
			res = Factory.create_menu
			@payloads.each do |h|
				res.add(h.slice)
			end
			return res
		end

		# if is the Header Menu
		klss = @header.class.to_s
		raise "Must LSA Class" unless klss.match(/^LSA.*Packet$/)
		tmp = @header.to_s[0,20]
		tmp_header = Factory.create_lsa_header_packet(:lsa_header => tmp)
		return tmp_header.menu
	end

	# If this is allMenu the @header must be Null
	# If this is LSA Header Menu the @header is lsa_header
	def slice!
		tmp_self = self.slice
		self.clear
		if @header == ""
			num = tmp_self.size
			num.times do |t|
				self.add tmp_self.get_child(t)
			end
			return self
		else
			@header = tmp_self.header
		end
			
	end

	def ospf_calc_lsa_cksum
		if @header == ""
			@payloads.each do |p|
				if p.header.class.to_s.match(/^LSA.*Packet$/)
					p.ospf_calc_lsa_cksum
				else
					next
				end
			end
		return
		end

		begin
			@header.ospf_calc_lsa_cksum(self.to_s)
		rescue
			raise "Not ospf_calc_lsa_cksum Methods, Please insert"
		end
	end

	def ospf_recalc_lsa(args = :all)
		case args
		when :cksum
			self.ospf_calc_lsa_cksum
		when :len
			self.ospf_calc_lsa_len
		when :lins
			self.ospf_calc_lsa_links
		when :all
			self.ospf_calc_lsa_links
			self.ospf_calc_lsa_len
			self.ospf_calc_lsa_cksum
		else
			raise "Only :cksum :len or :all"
		end
	end

	# Just for Router LSA
	def ospf_calc_lsa_links
		if @header == ""
			@payloads.each do |p|
				if p.header.class.to_s.match(/^LSARouterPacket$/)
					p.ospf_calc_lsa_links
				else
					next
				end
			end
			return
		end

		@header.ospf_calc_lsa_links
	end
			

			
		
	def method_missing(method, *args, &block)
		begin 
			super
		rescue
			@header.send(method.to_sym, *args, &block)
		end
	end
end
		

class MenuItem < Combo
	def initialize payload
		@payload = payload
	end

	def to_s
		@payload.to_s
	end

	def read str
	end

	# NOTE: The Body is clone
	def body=(v)
		@payload.clone.body = v
	end

	def payload
		return @payload
	end

	def to_pkt
		return @payload.clone
	end
		
	def method_missing(method, *args, &block)
		begin 
			super
		rescue
			@payload.send(method.to_sym, *args, &block)
		end
	end
end
		
