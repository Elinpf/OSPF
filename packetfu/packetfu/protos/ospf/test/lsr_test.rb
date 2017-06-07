load "structfu.rb"
load "ospf_header.rb"
load "ospf_lsr.rb"

puts "\tTest OSPF LS Request Packet instance"
ospf_lsr = OSPFLSR.new('ospf_lstype' => 4)
p ospf_lsr.to_s
p ospf_lsr.to_s.size

puts "\tTest LS ID"
ospf_lsr.ospf_lsid_quad = "1.2.3.4"
p ospf_lsr.ospf_lsid_quad
p ospf_lsr.ospf_lsid_str
p ospf_lsr.ospf_lsid
p ospf_lsr.to_s
