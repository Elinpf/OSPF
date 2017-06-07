load "core.rb"

hello = Factory.create_ospf_hello_packet
hello.ospf_hi = 30
hello.ospf_dr_quad = "192.168.18.1"
hello.ospf_recalc
str = hello.to_s 
p str

p OSPFHelloPacket.can_parse? str
hello_2 = Factory.create_ospf_hello_packet.read str
p hello_2
