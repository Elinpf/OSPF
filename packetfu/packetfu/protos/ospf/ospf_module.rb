module PacketFu
#
# Used in 
#   lsa_header.rb
#   ospf_lsr.rb
#   ospf_lsu.rb
#
#  Usage : 
#  ospf_inject(Factory.create_lsa_router, /^LSARouter$/)
#      or
#  ospf_inject([Factory.create_lsa_router, Factory.create_lsa_router], /^LSA/)
#
module Inject
        def ospf_inject(pkt, reg=//)
		if Array === pkt
			pkt.each do |p|
				if not p.class.to_s =~ reg
					raise "Must input like #{reg.to_s} Class"
				end
			end

			pkt_num = pkt.size
			# [3, 2, 1, 0]
			(0...pkt_num).to_a.reverse.each do |i|
				next if i == pkt_num - 1
				pkt[i].body = pkt[i+1]
			end
			@headers.last.body = pkt.first
			return @headers += pkt
		else
			if not pkt.class.to_s =~ reg
				raise "Must input like #{reg.to_s} Class"
			end
			@headers.last.body = pkt 
			@headers.push pkt 
		end
        end 
end
end

