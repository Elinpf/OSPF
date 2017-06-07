load "core.rb"

lsr = Factory.create_ospf_lsr_packet
lsr.ospf_get_lsr(0).ospf_ar_quad = "1.1.1.1"
header_menu_1 = Factory.create_ospf_lsr.menu
header_menu_1.ospf_ar_quad = "2.2.2.2"
header_menu_2 = Factory.create_ospf_lsr.menu
header_menu_2.ospf_ar_quad = "3.3.3.3"
lsr.ospf_inject_lsr header_menu_1
lsr.ospf_inject_lsr header_menu_2
str = lsr.to_s

lsr_2 = Factory.create_ospf_lsr_packet.read str
p lsr_2

=begin
lsr = Factory.create_ospf_lsr_packet
header_menu_1 = Factory.create_ospf_link.menu
header_menu_2 = Factory.create_ospf_link.menu
header_menu_3 = Factory.create_ospf_link.menu

lsr.ospf_inject_lsr header_menu_1
lsr.ospf_inject_lsr header_menu_2
lsr.ospf_inject_lsr header_menu_3

p lsr
lsr.ospf_lsrs_p
p lsr.to_s
=end
