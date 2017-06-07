=begin
  Neighbor Data Structure
NbrStateMachine		:machine	# State
Timer			:in_timer	# Inactivity Timer
Bool			:ms		# Master / Slave
Fixnum			:dd_seq		# DD Sequence 
OSPFDBDPacket		:last_dbd	# Last received Database Description packet
Octets			:nbr_id		# Neighbor ID
Fixnum			:nbr_pri	# Neighbor Priority
Octets			:nbr_ip_addr	# Neighbor IP Address
DBDOpt			:nbr_opts	# Neighbor Options
Octets			:nbr_dr		# Neighbor's Designated Router
Octets			:nbr_bdr	# Neighbor's Backup Designated Router
Array			:retrans_list	# Link state retransmission list
Menu			:summary_list	# Database summary list
Hash			:request_list	# Link state request list

=end

class Neighbor	< Struct.new(
		:machine, :in_timer, :ms, :dd_seq, :last_dbd,
		:nbr_id, :nbr_pri, :nbr_ip_addr, :nbr_opts, :nbr_dr, :nbr_bdr,
		:retrans_list, :summary_list, :request_list )
	include Singleton
	include StructFu
	def initialize(args={})
		super(
			#SingleFactory.create_machine,
			nil,
			Timer.new(args['in_timer'] || 40),
			false, # MS
			(args['dd_seq'] || rand(0xff)),
			Factory.create_ospf_dbd_packet,
			Octets.new(args['nbr_id'] || "\x00"*4),
			(args['nbr_pri'] || 0), 
			Octets.new(args['nbr_ip_addr'] || "\x00"*4),
			DBDOpt.new(args['nbr_opts'] || 0),
			Octets.new(args['nbr_dr'] || "\x00"*4),
			Octets.new(args['nbr_bdr'] || "\x00"*4),
			Array.new(args['retrans_list'] || 0),
			Menu.new(""), # summary_list
			Hash.new(args['request_list'] || 0) )
	end

	def machine
		self['machine']
	end

	def machine=(v)
		self['machine'] = v
	end

	def state
		self['machine'].state
	end

	def in_timer; 		self['in_timer']; 	end
	
	def ms;			self['ms'];		end
	def ms=(v)
		unless FalseClass === v or TrueClass === v
			raise "Input Bool type for ms= method"
		end
		self['ms'] = v
	end

	def dd_seq;		self['dd_seq'].to_i;	end
	def dd_seq=(v)
		raise ArgumentError unless Fixnum === v 
		self['dd_seq'] = v
	end

	def last_dbd
		self['last_dbd']
	end

	def last_dbd=(v)
		unless OSPFDBDPacket === v or ::String === v
			raise "Input OSPFDBDPacket Class or String for last_dbd= method"
		end
		self['last_dbd'].read v.to_s
	end

	def nbr_id;	self['nbr_id'].to_s;	end
	def nbr_id_i;	self['nbr_id'].to_i;	end
	def nbr_id=(v)
		self['nbr_id'].read v;	end
	def nbr_id_quad;self['nbr_id'].to_x;	end
	def nbr_id_quad=(v)
		self['nbr_id'].read_quad v
	end

	def nbr_pri;	self['nbr_pri'].to_i;	end
	def nbr_pri=(v)
		raise ArgumentError unless Fixnum === v
		self['nbr_pri'] = v;	end

	def nbr_ip_addr;	self['nbr_ip_addr'].to_s;	end
	def nbr_ip_addr=(v)
		self['nbr_ip_addr'].read v;	end
	def nbr_ip_addr_quad; 	self['nbr_ip_addr'].to_x;	end
	def nbr_ip_addr_quad=(v)
		self['nbr_ip_addr'].read_quad v
	end

	def nbr_opts;		self['nbr_opts'];		end
	def nbr_opts_i;		self['nbr_opts'].to_i;		end
	def nbr_opts=(v)
		raise ArgumentError unless Fixnum === v
		self['nbr_opts'].read v; 	end

	def nbr_dr;		self['nbr_dr'].to_s;	end
	def nbr_dr=(v)
		self['nbr_dr'].read v;	end
	def nbr_dr_quad;	self['nbr_dr'].to_x;	end
	def nbr_dr_quad=(v)
		self['nbr_dr'].read_quad v;	end

	def nbr_bdr;		self['nbr_bdr'].to_s;	end
	def nbr_bdr=(v)
		self['nbr_bdr'].read v;	end
	def nbr_bdr_quad;	self['nbr_bdr'].to_x;	end
	def nbr_bdr_quad=(v)
	        raise ArgumentError unless String === v
		self['nbr_bdr'].read_quad v;	end

	def retrans_list;	self['retrans_list'];	end
	def retrans_list=(v)
		unless Array === v
			raise "Input Array for retrans_list= method"
		end
		self['retrans_list'] = v
	end
	def add_retrans_list v
		self['retrans_list'] << v
	end

	
	def summary_list;	self['summary_list'];	end
	def summary_list=(v)
		unless Menu === v
			raise "Input Menu for summary_list= method"
		end
		self['summary_list'] = v
	end
	def add_summary_list v
		self['summary_list'] << v
	end

	def request_list;	self['request_list'];	end
	def request_list=(v)
		unless Hash === v
			raise "Input Hash for request_list= method"
		end
		self['request_list'] = v
	end
	def add_request_list(k,v)
		self['request_list'][k] = v
	end
end
