load "core.rb"

# LSU
lsu = Factory.create_ospf_lsu_packet

# set LSU
# eth
lsu.eth_saddr = "cc:01:29:94:00:00"
lsu.eth_daddr = "01:00:5e:00:00:05"

# ip
lsu.ip_saddr = "10.1.1.1"
lsu.ip_daddr = "224.0.0.5"
lsu.ip_ttl   = 1

lsu.ospf_rid_quad = "1.1.1.1"

# lsa
lsa = Factory.create_lsa_router_packet.menu
link_1 = Factory.create_lsa_link.menu_item
link_2 = Factory.create_lsa_link.menu_item
link_3 = Factory.create_lsa_link.menu_item

# set lsa
lsa.ospf_lsa_age = 1
lsa.ospf_lsa_seq = 0x8000002b
lsa.ospf_lsa_opt_set "dc", "e"
lsa.ospf_lsa_lsid_quad = "1.1.1.1"
lsa.ospf_lsa_ar_quad = "1.1.1.1"


# link 1
link_1.ospf_lsa_lkid_quad = "11.11.11.11"
link_1.ospf_lsa_lkdata_quad = "255.255.255.255"

# link 2
link_2.ospf_lsa_lkid_quad = "10.1.1.3"
link_2.ospf_lsa_lkdata_quad = "10.1.1.1"
link_2.ospf_lsa_lktype = 2
link_2.ospf_lsa_metric = 10

# link 3
link_3.ospf_lsa_lkid_quad = "12.1.1.0"
link_3.ospf_lsa_lkdata_quad = "255.255.255.0"
link_3.ospf_lsa_metric = 10


lsa.add link_1
lsa.add link_2
lsa.add link_3

# inject lsa to LSU
lsu.ospf_inject_lsa lsa

# recalc
lsu.ospf_recalc_lsu
lsu.ospf_recalc
lsu.ip_recalc

# socket
socket = Socket.create_eth0
#socket.send(lsu.to_s, 0);socket.close

puts "lsa:"
p lsa.to_s
p lsu
lsu.ospf_lsa_p
