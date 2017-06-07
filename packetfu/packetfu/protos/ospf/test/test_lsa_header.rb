load "core.rb"

puts "\tTest LSA Header"
lsa_header = Factory.create_lsa_header_packet
p lsa_header
