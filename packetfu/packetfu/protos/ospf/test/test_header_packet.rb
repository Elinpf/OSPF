load "core.rb"
include PacketFu
puts "\tTest OSPF Header Packet"

ospf_header = OSPFHeaderPacket.new

ospf_header.ospf_len = 20
str = ospf_header.to_s
ospf_header_2 = Factory.create_ospf_header_packet.read str
p ospf_header_2
