load "core.rb"
puts "\tTest LSA Router Packet"

router = Factory.create_lsa_router_packet(
		:lsa_link => [Factory.create_lsa_link,
		 Factory.create_lsa_link])
router.ospf_lsa_links = 2

puts "\tTest read"
str = router.to_s
router_2 =  Factory.create_lsa_router_packet.read str
p router_2

puts "\tTest ospf_get_lsa_link"
p router.ospf_get_lsa_link 1
