=begin
  Interface Data Structure:
Fixnum 		:type		# Type
Fixnum		:state		# State
Octets		:ip_addr	# IP interface address
Octets		:ip_mask	# IP interface mask
AreaID		:aid		# Area ID
Fixnum 		:hi		# HelloInterval
Fixnum		:rdead		# RouterDeadInterval
Fixnum		:delay		# InfTransDelay
Fixnum		:pri		# Router Priority
Timer 		:hello_timer	# Hello Timer
Timer 		:wait_timer	# Wait Timer
Array		:nbr_list	# List of neighboring routers
Octets		:dr		# Designated Router
Octets		:bdr		# Backup Designated Router
Fixnum		:cost		# Interface output cost(s)
Timer		:ri		# RxmtInterval
Fixnum		:au_type	# AuType
Fixnum		:au_key		# Authentication key

=end
class Interface < Struct.new(
		:type, :state, :ip_addr, :ip_mask,
		:aid, :hi, :rdead, :delay, :pri, 
		:hello_timer, :wait_timer, :nbr_list,
		:dr, :bdr, :cost, :ri, :au_type, :au_key)
	include Singleton
	include StructFu
	def initialize(args={})
	super(
		(args['type'] || 1),
		(args['state'] || 0),
		Octets.new(args['ip_addr'] || "\x00"*4),
		Octets.new(args['ip_mask'] || "\x00"*4),
		AreaID.new(args['aid'] || "\x00"*4),
		(args['hi'] || 10),
		(args['rdead'] || 40),
		(args['delay'] || 0),
		(args['pri'] || 1),
		Timer.new(args['hello_timer'] || 10),
		Timer.new(args['wait_timer'] || 40),
		Array.new(0), # nbr_list
		Octets.new(args['dr'] || "\x00"*4),
		Octets.new(args['bdr'] || "\x00"*4),
		(args['cost'] || 1),
		Timer.new(args['ri'] || 10),
		(args['au_type'] || 0),
		(args['au_key'] || 0)
	)
	end

	def type;	self['type'].to_i;	end
	def type=(v)
		self['type'] = v;	end
	
	def state;	self['state'].to_i;	end
	def state=(v);	self['state'] = v;	end
	
	def ip_addr;	self['ip_addr'].to_s; 	end
	def ip_addr=(v)
			self['ip_addr'].read v
	end
	def ip_addr_quad;	self['ip_addr'].to_x; 	end
	def ip_addr_quad=(v)
			self['ip_addr'].read_quad v
	end

	def ip_mask;	self['ip_mask'].to_s; 	end
	def ip_mask=(v)
			self['ip_mask'].read v
	end
	def ip_mask_quad;	self['ip_mask'].to_x; 	end
	def ip_mask_quad=(v)
			self['ip_mask'].read_quad v
	end

	def aid;	self['aid'].to_s;	end
	def aid_quad;	self['aid'].to_x;	end
	def aid_quad=(v)
			self['aid'].read_quad v
	end

	def hi;		self['hi'].to_i;	end
	def hi=(v)
		raise ArgumentError unless Fixnum === v
			self['hi'] = v
			self['hello_timer'].time = v
	end

	def rdead;	self['rdead'].to_i;	end
	def rdead=(v)
		raise ArgumentError unless Fixnum === v
			self['rdead'] = v
			self['wait_timer'].time = v	
	end

	def delay;	self['delay'].to_i;	end
	def delay=(v)
		raise ArgumentError unless Fixnum === v
			self['delay'] = v;	end

	def pri;	self['pri'].to_i;	end
	def pri=(v)
		raise ArgumentError unless Fixnum === v
			self['pri'] = v;	end

	def hello_timer; self['hello_timer'];	end
	def wait_timer;	 self['wait_timer'];	end
		
	def nbr_list; 	self['nbr_list'];	end
	def nbr_list=(v)
		raise "Input Array Class for nbr_list method" unless Array === v
		self['nbr_list'] = v
	end

	def add_nbr_list (v)
		raise ArgumentError unless ::String  === v
		self['nbr_list'] << v
	end

	def dr;		self['dr'].to_s;	end
	def dr=(v)
			self['dr'].read v;	end
	def dr_quad;	self['dr'].to_x;	end
	def dr_quad=(v)
			self['dr'].read_quad v
	end

	def bdr;	self['bdr'].to_s;	end
	def bdr=(v)
			self['bdr'].read v;	end
	def bdr_quad;	self['bdr'].to_x;	end
	def bdr_quad=(v)
			self['bdr'].read_quad v
	end

	def cost;	self['cost'].to_i;	end
	def cost=(v)
		raise ArgumentError unless Fixnum === v
			self['cost'] = v;	end

	def ri;		self['ri'];		end
	def ri=(v)
		self['ri'].time = v
	end

	attr_accessor  :au_type, :au_key
end



	
