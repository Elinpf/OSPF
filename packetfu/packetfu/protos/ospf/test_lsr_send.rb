load "core.rb"

lsr = Factory.create_ospf_lsr_packet

link_1 = Factory.create_ospf_lsr.menu
link_2 = Factory.create_ospf_lsr.menu
link_3 = Factory.create_ospf_lsr.menu

link_1.ospf_lsid_quad = "10.1.1.1"

# inject link to lsr
lsr.ospf_inject_lsr link_1
lsr.ospf_inject_lsr link_2
lsr.ospf_inject_lsr link_3

# calc
lsr.ospf_recalc
lsr.ip_recalc

# socket
socket = Socket.create_eth0
socket.send(lsr.to_s, 0); socket.close

p lsr

