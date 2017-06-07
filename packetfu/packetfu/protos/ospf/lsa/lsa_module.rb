
#
# This method is use inject like
# [@lsa_header, @lsa_router]
# first used in ospf_dbd.rb
#
class LSAInjectPacket
        def ospf_inject_lsa_packet(attr, pkt=nil, def_pkt, args)
                if pkt.nil?
                        if attr.nil?
                                attr = Factory.create_lsa_header_packet
                        else
                                attr.ospf_inject_lsa Factory.send(
					"create_lsa_#{def_pkt}", args)
                        end 
                else
                        if attr.nil?
                                attr = pkt 
                        else
                                attr.ospf_inject_lsa pkt 
                        end 
                end 
		return attr
        end 
end
