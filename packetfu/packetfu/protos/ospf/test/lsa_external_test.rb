load "core.rb"

puts "\tTest LSA Summary Packet"
lsa_summary = LSASummary.new
p lsa_summary.to_s
p lsa_summary.to_s.size

puts "\tTest LSA External Packet"
lsa_external = LSAExternal.new
p lsa_external.to_s
p lsa_external.to_s.size

puts "\tTest e bit set"
lsa_external.ospf_lsa_e_set
p lsa_external.ospf_lsa_e
p lsa_external.ospf_lsa_e_set?
p lsa_external.to_s
lsa_external.ospf_lsa_e_unset
p lsa_external.ospf_lsa_e_set?

puts "\tTest forwarding address"
lsa_external.ospf_lsa_fwd_quad = "192.168.18.1"
p lsa_external.ospf_lsa_fwd_quad
p lsa_external.to_s
