load "structfu.rb"
load "ospf_opt.rb"
load "ospf_header.rb"
load "ospf_hello.rb"

puts "\tTest OSPF Hello instance"
ospf_hello = OSPFHello.new
p ospf_hello.to_s
p ospf_hello.to_s.size

puts "\tTest OSPF network mask"
ospf_hello.ospf_netmask_quad = "255.255.255.0"
p ospf_hello.ospf_netmask
p ospf_hello.ospf_netmask_str
p ospf_hello.ospf_netmask_quad
p ospf_hello.to_s

puts "\tTest OSPF Hello Options set and unset"
puts "  set L and E flag"
ospf_hello.ospf_opt_set("L","E")
p ospf_hello.ospf_opt
p ospf_hello.to_s
puts "  unset L flag"
ospf_hello.ospf_opt_unset "l"
p ospf_hello.ospf_opt
p ospf_hello.to_s

puts "\tTest OSPF Hello read method"
puts "  build a new instance"
ospf_hello_2 = OSPFHello.new
ospf_hello_2.read(ospf_hello.to_s)
p ospf_hello_2.to_s

puts "\tTest OSPF Header and Hello"
ospf_header = OSPFHeader.new
ospf_header.body = ospf_hello
p ospf_header.to_s
p ospf_header.to_s.size

################### Before all Good !! ######################
