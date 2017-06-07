=begin
How to used
1.  send = Send.new
2.  send.init(iface, nbr, socket)
3.  send.set_dest

=end
class Send
	attr_accessor :socket
	attr_accessor :iface, :nbr
	attr_accessor :dst
	def initialize
		@hello  = Proc.new {|args| Factory.create_ospf_hello_packet(args) }
		@dbd    = Proc.new {|args| Factory.create_ospf_dbd_packet(args) }
		@lsr    = Proc.new { Factory.create_ospf_lsr_packet }
		@lsu    = Proc.new { Factory.create_ospf_lsu_packet }
		@lsack  = Proc.new { Factory.create_ospf_lsack_packet }

		@send_packet = nil
	end

	# Association Received Class
	def observer(notify_array)
		notify_array.each do |n|
			n.add_observer(self)
		end
	end

	def init(iface, nbr, socket)
		self.socket = socket
		self.iface = iface
		self.nbr = nbr
	end

	def set_dest(dst_ip, dst_mac)
		self.dst = [dst_ip, dst_mac]
	end

	def send_packet(packet,args={})
		packet.process
		@send_packet = packet.packet
		self.send
	end

	def send_hello(args={})
		hello = HelloSend.new(@hello.call(args), @iface, @nbr, @dst)
		self.send_packet(hello)
	end

	def send_dbd(args={})
		dbd = DBDSend.new(@dbd.call(args), @iface, @nbr, @dst)
		self.send_packet(dbd)
	end

	def send_lsr
	end

	def send_lsu
	end

	def send_lsack
	end

	def send 
		@socket.send(@send_packet.to_s, 0)
	end

	def update(func=nil, args={})
		case func
		when :hello
			self.send_hello
		when :dbd
			self.send_dbd
		when :lsr
			self.send_lsr
		when :lsu
			self.send_lsu(args[:menu])
		when :lsack
			self.send_lsack
		end
	end
end

class PacketSend
	attr_accessor :packet
	def initialize(packet, iface, nbr, dst)
		@packet = packet
		@iface = iface
		@nbr   = nbr
		@dst   = dst
	end

	def process
		raise "Must override this method"
	end

	def packet_init
		set_dst_ip()
		set_src_ip()
		set_ip_addr()
		set_rid()
		set_aid()
	end

	def set_dst_ip
		@packet.ip_daddr = @dst[0]
		@packet.eth_dst = @dst[1]
	end

	def set_src_ip
		self.set_ip_addr
	end

	def set_ip_addr
		@packet.ip_src = @iface.ip_addr
	end

	def set_rid
		@packet.ospf_rid = @iface.ip_addr
	end

	def set_aid
		@packet.ospf_aid = @iface.aid
	end

	def recalc
		@packet.ospf_recalc
		@packet.ip_recalc
	end
end
	

class HelloSend < PacketSend
	def process
		packet_init()
		set_ip_mask()
		set_hi()
		set_rdead()
		set_pri()
		set_opt()
		set_nbr_id()
		set_nbr_list()
		set_dr()
		set_bdr()
		recalc()
		return @packet
	end

	def set_ip_mask
		@packet.ospf_netmask = @iface.ip_mask
	end

	def set_hi
		@packet.ospf_hi = @iface.hi
	end

	def set_rdead
		@packet.ospf_rdead = @iface.rdead
	end

	def set_pri
		@packet.ospf_pri = @iface.pri
	end

	def set_opt
		@packet.ospf_opt_set "e"
	end

	def set_nbr_id
		# if p2p ip_src
		# if broadcast p2mp NMBA, ospf_rid
		@packet.ospf_rid = @iface.ip_addr
	end

	def set_nbr_list
		if @iface.nbr_list.empty?
			@packet.ospf_nbr_quad = "0.0.0.0"
		else
			@packet.ospf_nbr = @iface.nbr_list.first
		end
	end

	def set_dr
		@packet.ospf_dr = @iface.dr
	end

	def set_bdr
		@packet.ospf_bdr = @iface.bdr
	end

	def recalc
		if @packet.ospf_nbr == 0
			@packet.ospf_len = 44
		else
			@packet.ospf_len = 48
		end
		@packet.ospf_recalc(:ospf_cksum)
		@packet.ip_recalc
	end
end
			

class DBDSend < PacketSend
	def process
		# if not sub network
		packet_init()
		set_mtu()
		set_opt()
		case @nbr.state
		when ExStartState
			set_nbr_opt(:i, :m, :ms )
			# RxmtInterval retrans
		when ExChangeState
			set_dd_seq()
			set_nbr_opt()
			set_lsa_summary()
			# when recv before confim packet, delete summary_list about confim
		when LoadingState, FullState
		end

		recalc()
		return @packet
	end

	def set_mtu
		@packet.ospf_mtu = 1500
	end

	def set_opt
		@packet.ospf_opt_set "e"
	end

	# two way to use this method
	# if args is empty, then set Neighbor data struceture
	# also can set by self
	def set_nbr_opt(*args)
		if args.empty?
			@packet.ospf_dbd_opt = @nbr.nbr_opts
		else
			args.each do |f|
				@packet.ospf_dbd_opt_set f.to_s
			end
		end
	end

	def set_dd_seq
		@packet.ospf_seq = @nbr.dd_seq
	end

	# Each 5 lsa headers in summary_list. input to @packet
	def set_lsa_summary
		lsa_menu = @nbr.summary_list
		res = lsa_menu.get_range 5
		res.each do |lsa|
			@packet.ospf_lsa_headers_class << lsa
		end
	end
end
		
			
	
				
		
			
			
			


		


