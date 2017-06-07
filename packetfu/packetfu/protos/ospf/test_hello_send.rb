load "core.rb"

socket = Socket.create_eth0

hello = Factory.create_ospf_hello_packet

hello.eth_src = Socket.getmyhostmac
hello.eth_daddr = "cc:01:32:34:00:00"
hello.ip_saddr = Socket.getmyhostip
hello.ip_daddr = "192.168.18.200"
#hello.ip_proto = 89
hello.ip_tos = 192
# TTL value to 1 for Local Network
hello.ip_ttl = 32

hello.ospf_rid_quad = "192.168.18.136"
hello.ospf_netmask_quad = "255.255.255.0"
hello.ospf_dr_quad = "192.168.18.136"

hello.ospf_opt_set "e", "l"


# calc
hello.ospf_len = 44
hello.ospf_recalc(:ospf_cksum)
hello.ip_recalc

# send
socket.send(hello.to_s, 0); socket.close
p hello
