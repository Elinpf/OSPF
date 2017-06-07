load "structfu.rb"
load "ospf_opt.rb"
load "ospf_header.rb"
load "lsa_header.rb"

puts "\tTest LSA Header instance"
lsa_header = LSAHeader.new
p lsa_header.to_s
p lsa_header.to_s.size

puts "\tTest Sequence"
p lsa_header.ospf_lsa_seq
p lsa_header.ospf_lsa_seq_inc
p lsa_header.ospf_lsa_seq

puts "\tTest Checksum"
p lsa_header.ospf_lsa_cksum
p lsa_header.ospf_calc_lsa_cksum
p lsa_header.ospf_lsa_cksum_str
p lsa_header.ospf_lsa_cksum
p lsa_header.ospf_rand_lsa_cksum
p lsa_header.ospf_lsa_cksum

puts "\tTest age"
p lsa_header.ospf_lsa_age

puts "\tTest ar"
p lsa_header.ospf_lsa_ar
lsa_header.ospf_lsa_ar_quad = "192.168.18.1"
p lsa_header.ospf_lsa_ar_str
p lsa_header.to_s
