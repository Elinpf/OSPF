# Test OSPF LSAck Packet 
load "core.rb"

lsack = Factory.create_ospf_lsack_packet

header_menu_1 = Factory.create_lsa_header_packet_router.menu
header_menu_2 = Factory.create_lsa_header_packet_network.menu

lsack.ospf_inject_lsa header_menu_1
lsack.ospf_inject_lsa header_menu_2

p lsack
lsack.ospf_lsa_headers_p
str =  lsack.to_s
p str
p str.size

# Test Read

lsack_2 = Factory.create_ospf_lsack_packet
lsack_2.read str

p lsack_2
lsack_2.ospf_lsa_headers_p
p lsack_2.to_s.size


############## All Good!! ##############


