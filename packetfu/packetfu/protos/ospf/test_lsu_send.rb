load "core.rb"

lsu = Factory.create_ospf_lsu_packet

# Router LSA
header_menu_1 = Factory.create_lsa_router_packet.menu
link_1 = Factory.create_lsa_link.menu_item
link_2 = Factory.create_lsa_link.menu_item
link_3 = Factory.create_lsa_link.menu_item


header_menu_1.add link_1
header_menu_1.add link_2
header_menu_1.add link_3

# calc Router LSA links number, LSA len and  checksum
#header_menu_1.ospf_calc_lsa_links
#header_menu_1.ospf_calc_lsa_len
#header_menu_1.ospf_calc_lsa_cksum
# or
#header_menu_1.ospf_recalc_lsa

# Network LSA
header_menu_2 = Factory.create_lsa_network_packet.menu
network_1 = Factory.create_lsa_attrouter.menu_item
network_2 = Factory.create_lsa_attrouter.menu_item
network_3 = Factory.create_lsa_attrouter.menu_item

#header_menu_2.add network_1
#header_menu_2.add network_2
#header_menu_2.add network_3

# Summary IP LSA
header_menu_3 = Factory.create_lsa_summary_ip_packet.menu

# Summary ASBR LSA
header_menu_4 = Factory.create_lsa_summary_asbr_packet.menu

# External LSA
header_menu_5 = Factory.create_lsa_external_packet.menu

# inject LSA to LSUpdate Packet
lsu.ospf_inject_lsa header_menu_1
lsu.ospf_inject_lsa header_menu_2
lsu.ospf_inject_lsa header_menu_3
lsu.ospf_inject_lsa header_menu_4
lsu.ospf_inject_lsa header_menu_5


# recalc
# NOTE recalc lsanum
#lsu.ospf_calc_lsanum
lsu.ospf_recalc_lsu
lsu.ospf_recalc
lsu.ip_recalc

# send
socket = Socket.create_eth0
socket.send(lsu.to_s, 0); socket.close

# output
p lsu
lsu.ospf_lsa_p


