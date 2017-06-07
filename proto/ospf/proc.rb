load "core.rb"


eth_dest = "cc:01:29:94:00:00".split(":").map {|x| x.to_i(16)}.pack("C6")
dest = ["10.1.1.1", eth_dest]
src = [Socket.getmyhostip, "00:0c:29:88:06:5c".split(":").map {|x| x.to_i(16)}.pack("C6")]

iface = SingleFactory.create_iface
nbr   = SingleFactory.create_nbr
machine = SingleFactory.create_machine
recv = Receive.new
send = Send.new
socket = Socket.create_eth0
capture = Capture.new
lsa_db = SingleFactory.create_lsa_db

# Init
iface.dr_quad = src[0]
nbr.machine = machine
filter = "dst host not #{Socket.getmyhostip} and ip proto ospf"
#filter = "ip proto ospf"
capture.capture(:filter => filter)
iface.ip_addr_quad = Socket.getmyhostip
iface.ip_mask_quad = "255.255.255.0"
recv.init(iface, nbr, lsa_db)
send.init(iface, nbr, socket)
send.set_dest(dest[0], dest[1])
send.observer(recv.notify)

# set
# summary_list
menu = Factory.create_menu
lsa_1 = Factory.create_lsa_router_packet.menu
lsa_2 = Factory.create_lsa_router_packet.menu
lsa_3 = Factory.create_lsa_router_packet.menu
lsa_4 = Factory.create_lsa_router_packet.menu
lsa_5 = Factory.create_lsa_router_packet.menu
lsa_6 = Factory.create_lsa_router_packet.menu
menu << lsa_1
menu << lsa_2
menu << lsa_3
menu << lsa_4
menu << lsa_5
menu << lsa_6
menu.ospf_recalc_lsa
menu.slice!
nbr.summary_list = menu

# set hello timer
iface.hi = 10

# Send Hello by Timer
args = {:ip_ttl => 1,
	:eth_src => src[1],
	}
#send.send_hello(args)
iface.hello_timer.run {send.send_hello(args)}


# Send dbd packet
#nbr.machine.changeto_exstart_state
#send.send_dbd

#nbr.machine.changeto_exchange_state
#send.send_dbd

loop do 
	str = capture.next
	if not str.nil?
		recv.recv str
#send.send_dbd(args)
	end
end

	
