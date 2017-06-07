load "structfu.rb"
load "ospf_opt.rb"
load "ospf_header.rb"
load "ospf_dbd.rb"

puts "\tTest OSPF DB Description instance"
ospf_dbd = OSPFDBD.new
p ospf_dbd.to_s
p ospf_dbd.to_s.size

puts "\tTest DBD Options"
puts "  set i and m and ms flag"
ospf_dbd.ospf_dbd_opt_set "i", "m", "ms"
p ospf_dbd.ospf_dbd_opt
p ospf_dbd.to_s

puts "  unset i and ms"
ospf_dbd.ospf_dbd_opt_unset "i", "ms"
p ospf_dbd.ospf_dbd_opt
p ospf_dbd.to_s

