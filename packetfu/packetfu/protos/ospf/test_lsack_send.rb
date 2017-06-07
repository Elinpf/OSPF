load "core.rb"

lsack = Factory.create_ospf_lsack_packet

# create base Menu Class
menu = Factory.create_menu

# Router LSA
lsa_1 = Factory.create_lsa_router_packet.menu
link_1 = Factory.create_lsa_link.menu_item

lsa_1.add link_1

# Network LSA
lsa_2 = Factory.create_lsa_network_packet.menu
network_1 = Factory.create_lsa_attrouter.menu_item

lsa_2.add network_1

# Summary IP LSA
lsa_3 = Factory.create_lsa_summary_ip_packet.menu

# Summary ASBR LSA
lsa_4 = Factory.create_lsa_summary_asbr_packet.menu

# External LSA
lsa_5 = Factory.create_lsa_external_packet.menu

# inject to menu
menu.add lsa_1
menu.add lsa_2
menu.add lsa_3
menu.add lsa_4
menu.add lsa_5

# recalc LSA
menu.ospf_recalc_lsa

# slice!
menu.slice!

# replace the LSAck ospf_lsa_headers Menu
lsack.ospf_lsa_headers = menu

# recalc OSPF and IP
lsack.ospf_recalc
lsack.ip_recalc

# send
socket = Socket.create_eth0
socket.send(lsack.to_s, 0); socket.close

# output
p lsack
lsack.ospf_lsa_p

