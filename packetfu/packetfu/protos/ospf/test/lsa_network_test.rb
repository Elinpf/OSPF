load "core.rb"

puts "\tTest LSA Network Packet"
lsa_network = LSANetwork.new('ospf_lsa_netrouter' => [LSANetRouter.new])
p lsa_network.to_s
p lsa_network.to_s.size

lsa_network.ospf_inject_lsa_netrouter LSANetRouter.new
p lsa_network.to_s
p lsa_network.to_s.size

puts "\tTest read"
lsa_network_2 = LSANetwork.new.read(lsa_network.to_s)
p lsa_network_2.to_s

