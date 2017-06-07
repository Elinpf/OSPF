=begin
Usage:
	menu = Menu.new(Factory.create_lsa_header_packet)
	router_1 = MenuItem.new(Factory.create_lsa_router)
	router_2 = MenuItem.new(Factory.create_lsa_router)

	menu.add router_1
	menu.add router_2
	menu.to_pkt

	lsu.ospf_inject_lsa menu
	lsu.ospf_lsa_packet_p
:NOTE:Router LSA can single create packet

All of LSA type is alread
=end
load "core.rb"
lsu = Factory.create_ospf_lsu_packet

# Router LSA
header_menu = Menu.new(Factory.create_lsa_router_packet)
router_link_1 = MenuItem.new(Factory.create_lsa_link)
router_link_2 = MenuItem.new(Factory.create_lsa_link)
header_menu.add router_link_1
header_menu.add router_link_2

# Network LSA
header_menu_2 = Menu.new(Factory.create_lsa_network_packet)
network_1 = MenuItem.new(Factory.create_lsa_attrouter)
network_2 = MenuItem.new(Factory.create_lsa_attrouter)
header_menu_2.add network_1
header_menu_2.add network_2

# Summary LSA
header_menu_3 = Menu.new(Factory.create_lsa_summary_packet('ospf_lsa_lstype' => 4))
summary_1 = MenuItem.new(Factory.create_lsa_summary)
summary_2 = MenuItem.new(Factory.create_lsa_summary)
header_menu_3.add summary_1
header_menu_3.add summary_2

# External LSA
header_menu_4 = Menu.new(Factory.create_lsa_external_packet)
external_1 = MenuItem.new(Factory.create_lsa_external)
header_menu_4.add external_1


# Inject LSA Menu
lsu.ospf_inject_lsa header_menu
lsu.ospf_inject_lsa header_menu
lsu.ospf_inject_lsa header_menu_2
lsu.ospf_inject_lsa header_menu_3
lsu.ospf_inject_lsa header_menu_4
# Recalc lsa num
lsu.ospf_calc_lsanum

# Output
p lsu

lsu.ospf_lsa_packets_p

p lsu.to_s
