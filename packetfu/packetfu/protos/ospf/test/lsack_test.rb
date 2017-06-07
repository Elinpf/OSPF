load "structfu.rb"
load "arrayfu.rb"
load "ospf_header.rb"
load "ospf_lsack.rb"

puts "\tTest OSPF LSAck Packet"
ospf_lsack = OSPFLSAck.new('body' => ["\x01\x02\x03\x04", "\x11\x12\x13\x14"])
ospf_lsack.inject_lsa_headers("\x21\x22\x23\x24", "\x31\x32\x33\x34")
p ospf_lsack.body
p ospf_lsack.to_s


