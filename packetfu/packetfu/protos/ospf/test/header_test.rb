load "structfu.rb"
load "ospf_header.rb"

ot = "\x02\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"

## Test ospf to read
puts "\tText ospf to read"
ospf_header = OSPFHeader.new
ospf_header.read ot

## Test ver type auth for Int64
puts "\tTest ver type auth for Int64"
p ospf_header.ospf_ver
p ospf_header.ospf_type
p ospf_header.ospf_auth

## Test route_id for quad
puts "\tTest route-id for quad"
ospf_header.ospf_rid_quad = "192.168.18.1"
p ospf_header.ospf_rid
p ospf_header.ospf_rid_quad

## Test Area_id for int and quad
puts "\tTest area id for int and quad"
ospf_header.ospf_aid_i = 1
p ospf_header.ospf_aid
p ospf_header.ospf_aid_quad

##################### Before All Good !! #####################
puts "\tTest calc length and cheacksum"
len = ospf_header.ospf_calc_len
p len
 ospf_header.ospf_len = len
ck = ospf_header.ospf_calc_cksum
p ck
 ospf_header.ospf_cksum = ck
p ospf_header.to_s

