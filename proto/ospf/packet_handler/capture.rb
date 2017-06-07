
#
# @cap = Conn::Capture.new.run
# @cap.show_live(:filter => "icmp or arp")
# @cap.each_packet(:filter => "icmp or arp") {|pkt| pkt.to_s}
#
class Capture

	class CaptureError < StandardError; end

	attr_accessor :stream, :array
	attr_reader :iface, :snaplen, :promisc, :timeout

	def initialize(args={})
		@iface = args[:iface] || 'eth0'
		@snaplen = args[:snaplen] || 0xffff
		@promisc = args[:promisc] || false
		@timeout = args[:timeout] || 1

		@array = []

		setup_argument(args)
	end

	def setup_argument(args={})
		start = args[:start] || false
		capture(args) if start
	end

	#
	# the method is :start to the recv from interface and save in :stream
	#
	def capture(args={})
		# check up the user is not root ?
		if Process.euid.zero? 	
			filter = args[:filter]
			start = args[:start] || true
			if start
				begin
					@stream = Pcap.open_live(@iface,@snaplen,@promisc,@timeout)
				rescue RuntimeError
					raise CaptureError, "I think you don't have root privilege!"
				end
				bpf(:filter => filter) if filter
			else
				@stream = []
			end
			return @stream
		else
			raise CaptureError, "I think you don't have root privilege!"
		end
	end

	#
	# Start to recv the packet
	#
	def start
		capture(:start => true)
		self
	end

	def run
		capture(:start => true)
		self
	end

	#
	# Return the next packet
	#
	def next
		@stream.next rescue $stderr.puts "Do you start the capture?"
	end

#
# After two methods is to filter the packet.
#
	def bpf(args={})
		filter = args[:filter]
		@stream.setfilter(filter)
	end

	def setfilter(filter)
		bpf(:filter => filter)
	end

	#
	# Clear the buff
	#
	def clear
		@array = []
		@stream = []
	end

	#
	# Write the packet in the Array and Return the size
	#
	def write_to_array(args)
		# ensure the capture is run
		capture if @stream.class == Array

		filter = args[:filter]
		bpf(:filter => filter) if filter

		while pkt = @stream.next
			@array << pkt
		end
		@array.size
	end

	def save(args={})
		write_to_array(args)
	end

	#
	# This method can Given block
	#
	def each_fromt(args={}, &block)
		capture if @stream.class == Array
		setfilter(args[:filter]) if args[:filter]
		_save_ = true if args[:save]
		_each_ = true if args[:each] 
		_show_live_ = true if args[:show_live]

		@stream.each do |pkt|
			peek = PacketPf.parse!(pkt)
			yield peek if _each_
			puts peek.peek_fromt if _show_live_
			@array << peek if _save_
		end
	end

	# This method is show the peek_fromt
	def show_live(args={})
		each_fromt(	:show_live => true,
				:save => args[:save],
				:filter => args[:filter],
				)
	end

	# This method is operation every packet
	def each_packet(args={}, &block)
		each_fromt(	:each => true, 
				:filter => args[:filter],
				&block)
	end
			
end 	# class Capture
