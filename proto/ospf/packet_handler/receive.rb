require "observer"
class Receive
	attr_accessor :iface, :nbr, :lsa_db
	attr_reader :capture
	def initialize
		@hello 	= Factory.create_ospf_hello_packet
		@dbd	= Factory.create_ospf_dbd_packet
		@lsr	= Factory.create_ospf_lsr_packet
		@lsu	= Factory.create_ospf_lsu_packet
		@lsack 	= Factory.create_ospf_lsack_packet
		
		@recv = nil
		@parse = Parse.new

		@packet = nil
	end

	def init(iface, nbr, lsa_db)
		self.iface = iface
		self.nbr   = nbr
		self.lsa_db = lsa_db
		@@hello_recv = HelloReceive.instance
		@@hello_recv.init(@iface, @nbr)


		@@dbd_recv = DBDReceive.instance
		@@dbd_recv.init(@iface, @nbr)

		@@lsr_recv = LSRReceive.instance
		@@lsr_recv.init(@iface, @nbr)
		@@lsr_recv.lsa_db = lsa_db
	end

	def recv str
		@parse.packet = str
		if @parse.can_parse?
			case @parse.type
			when 1
				@packet = @hello.read str
			when 2
				@packet = @dbd.read str
			when 3
				@packet = @lsr.read str
			when 4
				@packet = @lsu.read str
			when 5
				@packet = @lsack.read str
			else
				raise "Can't parse OSPF type"
			end
		else
			return 
		end

		if @parse.is_hello?
			# if received hello packet, also a hello_timer send
			hello_recv = HelloReceive.instance
			hello_recv.packet = @packet
			hello_recv.process
		elsif @parse.is_dbd?
			dbd_recv = DBDReceive.instance
			dbd_recv.packet = @packet
			dbd_recv.process
		elsif @parse.is_lsr?
			lsr_recv = LSRReceive.instance
			lsr_recv.packet = @packet
			lsr_recv.lsa_db = lsa_db
			lsr_recv.process
		else
			puts "Not write"
		end
	end

	def notify
		notify_array = []
		notify_array << HelloReceive.instance
		notify_array << DBDReceive.instance
		notify_array << LSRReceive.instance

		return notify_array
	end
end


class PacketReceive
	include Singleton
	include Observable
	attr_accessor :packet
	attr_accessor :iface, :nbr
	def process
		raise "Must override this method"
	end

	def init(iface, nbr)
		@iface, @nbr = iface, nbr
	end
end



class HelloReceive < PacketReceive
	def process
		input_nbr_pri()
		input_nbr_ip_addr()
		input_nbr_opts()
		input_dr()
		input_bdr()
		if @packet.ospf_len >= 48
			# this is first hello packet for Nbr
			# Not have Active Neighbour
			input_nbr_list()
		end
		if @iface.nbr_list.include? @iface.ip_addr
			@nbr.machine.hello_received
		end
	end

	def input_nbr_pri
		@nbr.nbr_pri = @packet.ospf_pri
	end

	def input_nbr_ip_addr
		@nbr.nbr_ip_addr = @packet.ospf_rid_str
	end

	def input_nbr_opts
		@nbr.nbr_opts = @packet.ospf_opt
	end

	def input_dr
		@nbr.nbr_dr = @packet.ospf_dr_str
	end

	def input_bdr
		@nbr.nbr_bdr = @packet.ospf_bdr_str
	end

	def input_nbr_list
		@iface.add_nbr_list [@packet.ip_src].pack("N")
	end
end
		

class DBDReceive < PacketReceive
	def process
		input_last_dbd()
		case @nbr.state
		when DownState, AttemptState, TwoWayState
			return
		when InitState
			@nbr.machine.two_way_received
		when ExStartState
			input_nbr_opt()
			dispose_dd_seq()
			if bigger_rid?()
				set_ms(:slave)
				set_dd_seq()
				set_nbr_opt(:i => false, :ms => false)
			else
				set_ms(:master)
			end
			@nbr.machine.negotiation_done
		when ExChangeState
			return if repeat_dd?()
			return unless check_dd_seq()
			return unless dispose_ms()
			return if dispose_nbr_opt()
			dispose_lsa()
			dispose_dd_seq()
			last()
		when LoadingState, FullState
			return if dispose_nbr_opt()
		else
			return
		end
		
		def dispose_lsa
			# Each LSA
			@packet.ospf_lsa_headers.each do |lsa|
				return unless check_lsa(lsa)
				if not has_lsa?(lsa)
					add_request_list(lsa)
				end
			end
		end

		def last
			if ms?()
				if not @packet.ospf_dbd_opt_set? "m" and \
						@nbr.nbr_opts.has_set? "m"
					@nbr.machine.exchange_done
				end
			else
				if not @packet.ospf_dbd_opt_set? "m" and \
						@nbr.nbr_opts.has_set? "m"
					@nbr.machine.exchange_done
				end
			end
		end
	end

	def input_last_dbd
		@nbr.last_dbd = @packet
	end

	def input_nbr_opt
		@nbr.nbr_opts = @packet.ospf_dbd_opt
	end

	def dispose_dd_seq
		if ExStartState === @nbr.state
			@nbr.dd_seq += 1
		elsif ExChangeState === @nbr.state
			# if is Slave: Next dd_seq is dd_seq + 1
			# if is Master: Next dd_seq is self
			if @nbr.ms == false
				@nbr.dd_seq += 1
			end
		end
	end

	# Witch Router id is Bigger ?
	def bigger_rid?
		@packet.ospf_rid > @nbr.nbr_id_i ? true : false
	end

	def set_ms(ms = :master)
		@nbr.ms = case ms
			  when :master
			  	true
			  when :slave
			  	false
			  end
	end

	def set_dd_seq
		@nbr.dd_seq = @packet.ospf_seq
	end

	def set_nbr_opt(args={})
		args.each_pair do |k, v|
			if v == true
				@nbr.nbr_opts.opt_set(k.to_s.downcase)
			elsif v == false
				@nbr.nbr_opts.opt_unset(k.to_s.downcase)
			else
				return
			end
		end
	end
			
	# if received a repeat DBD Packet, Ignore
	def repeat_dd?
		@nbr.last_dbd == @packet ? true : false
	end

	# if ms Flag is not equal, generate Seqnumber Mismatch event
	def dispose_ms
		p = @packet.ospf_dbd_opt_set? "m"
		n = @nbr.ms
		if not p == n
			@nbr.machine.seqnumber_missmatch
			return false
		else
			return true
		end
	end

	# if ospf_dbd_opt has set I flag , generate Seqnumber Missmatch event
	def dispose_nbr_opt
		p = @packet.ospf_dbd_opt_set? "i" 
		if p 
			@nbr.machine.seqnumber_missmatch
		end
		p
	end

	def check_lsa lsa
		res = [1,2,3,4,5,7].include? lsa.ospf_lsa_lstype
		if not res
			@nbr.machine.seqnumber_missmatch
		end
		res
	end

	def hsa_lsa? lsa
		requset_list.has_key? lsa.ospf_lsa_cksum 
	end

	def add_request_list lsa
		cksum = lsa.ospf_lsa_cksum
		@nbr.add_request_list(cksum, lsa)
	end

	def check_dd_seq
		@nbr.dd_seq == @packet.ospf_seq
	end

	def ms?
		@nbr.ms
	end

end 	# DBD Receive

	

class LSRReceive < PacketReceive
	attr_accessor :lsa_db
	def process
		case @iface.state
		when ExChangeState, LoadingState, Full
			num = @packet.ospf_lsa_num
			lsu_menu = Factory.create_menu
			num.times do |t|
				tmp_lsr = @packet.ospf_get_lsr(t)
				# complete_lsa is Hash
				complete_lsa = @lsa_db.get_by_lsr(tmp_lsr)
				if complete_lsa.empty?
					return @iface.state.bad_lsareq
				end
				lsu_menu << complete_lsa[0].menu
			end
			notify(:lsu, {:menu => lsu_menu})
		else
			return
		end
	end
end	# LSRReceive Class
		
				
				

			

			

	
