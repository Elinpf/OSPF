load "core.rb"

dbd = Factory.create_ospf_dbd_packet

dbd.ip_ttl = 1


# Fist method to inject
menu = Factory.create_menu
lsa_1 = Factory.create_lsa_router_packet.menu
lsa_2 = Factory.create_lsa_network_packet.menu

menu.add lsa_1
menu.add lsa_2

#menu.ospf_calc_lsa_len
#menu.ospf_calc_lsa_cksum
menu.ospf_recalc_lsa
menu.slice!


# inject
#dbd.ospf_inject_lsa menu
dbd.ospf_lsa_headers = menu



=begin 
 Secend method to inject
lsa_1.ospf_recalc_lsa
lsa_2.ospf_recalc_lsa
lsa_1.slice!
lsa_2.slice!
dbd.ospf_inject_lsa lsa_1
dbd.ospf_inject_lsa lsa_2
=end

# calc
dbd.ospf_recalc
dbd.ip_recalc

# send
socket = Socket.create_eth0
socket.send(dbd.to_s, 0); socket.close

# output
p dbd
menu.to_pkt
p menu.size
