load "core.rb"

dbd = Factory.create_ospf_dbd_packet
dbd.ospf_opt_set "dc","l"
dbd.ospf_dbd_opt_set "r","ms"
dbd.ospf_opt_unset "L"
dbd.ospf_dbd_opt_unset "MS"


header_menu_1  = Factory.create_lsa_header_packet.menu
header_menu_1.ospf_lsa_ar_quad = "10.1.1.1"
header_menu_2  = Factory.create_lsa_header_packet.menu
header_menu_2.ospf_lsa_ar_quad = "10.2.2.2"

dbd.ospf_inject_lsa header_menu_1
dbd.ospf_inject_lsa header_menu_2

# Output
p dbd
dbd.ospf_lsa_headers_p
str = dbd.to_s
p str
p str.size

# Read
dbd_2 = Factory.create_ospf_dbd_packet
dbd_2.read str
p dbd_2
dbd_2.ospf_lsa_headers_p

########### All Good! ###########

