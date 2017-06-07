load "core.rb"

puts "\tTest Router LSA Packet instance"
lsa_router = LSARouter.new
p lsa_router.to_s
p lsa_router.to_s.size
p lsa_router.ospf_lsa_link
puts "  calc lsa link number"
p lsa_router.ospf_calc_lsa_links

puts "\tTest inject LSA Link"
lsa_router.ospf_inject_lsa_link(LSALink.new.to_s)
p lsa_router.to_s

puts "\tTest inject second LSA Link"
lsa_router.ospf_inject_lsa_link(LSALink.new('ospf_lsa_lkid' => "\x11\x12\x13\x14"))
p lsa_router.to_s

puts "\tTest inject a Array LSA Link"
lsa_router.ospf_inject_lsa_link([LSALink.new('ospf_lsa_lkid' => "\x14\x14\x14\x14"),
		LSALink.new])
p lsa_router.to_s
p lsa_router.to_s.size

puts "\tTest get first LSA"
p (lsa_router.ospf_index_lsa_link 0).to_s

puts "\tTest get Second LSA"
p (lsa_router.ospf_index_lsa_link 1).to_s

puts "\tTest calc link number"
lsa_router.ospf_calc_lsa_links
p lsa_router.ospf_lsa_links
p lsa_router.to_s

puts "\tTest Read"
pkt = "\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\x00\x01\x11\x12\x13\x14\x00\x00\x00\x00\x03\x00\x00\x01"
lsa_router_2 = LSARouter.new.read(pkt)
p lsa_router_2.to_s


