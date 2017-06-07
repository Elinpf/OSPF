# Test to read LSA Packet
load "core.rb"

lsu = Factory.create_ospf_lsu_packet

# Router LSA
header_menu_1 = Factory.create_lsa_router_packet.menu
link_1 = Factory.create_lsa_link('ospf_lsa_lkid' => "\x01\x02\x03\x04").menu_item
link_2 = Factory.create_lsa_link('ospf_lsa_lkid' => "\x05\x06\x07\x08").menu_item
link_3 = Factory.create_lsa_link.menu_item
header_menu_1.add link_1
header_menu_1.add link_2
header_menu_1.add link_3

# calc lsa links num
header_menu_1.ospf_calc_lsa_links
lsu.ospf_inject_lsa header_menu_1

# Network LSA
#header_menu = Factory.create_lsa_network_packet('ospf_lsa_len' => 32).menu
header_menu_2 = Factory.create_lsa_network_packet.menu
network_1 = Factory.create_lsa_attrouter(
		'ospf_lsa_attrouter' => "\x01\x02\x03\x04").menu_item
network_2 = Factory.create_lsa_attrouter.menu_item
network_3 = Factory.create_lsa_attrouter.menu_item
header_menu_2.add network_1
header_menu_2.add network_2
header_menu_2.add network_3

lsu.ospf_inject_lsa header_menu_2

# Summary_IP LSA
header_menu_3 = Factory.create_lsa_summary_ip_packet.menu
header_menu_3.ospf_lsa_metric = 10

lsu.ospf_inject_lsa header_menu_3

# Summary_ASBR LSA
header_menu_4 = Factory.create_lsa_summary_asbr_packet.menu

lsu.ospf_inject_lsa header_menu_4

# External LSA
header_menu_5 = Factory.create_lsa_external_packet.menu

lsu.ospf_inject_lsa header_menu_5

# calc
lsu.ospf_calc_lsanum
lsu.ospf_calc_lsa_len

# Output
p lsu
lsu.ospf_lsa_packets_p

str = lsu.to_s
p str.size
p str
# Test to read lsu packet
lsu = Factory.create_ospf_lsu_packet
lsu.read str
p lsu
lsu.ospf_lsa_packets_p

############## All Good!! ##############
