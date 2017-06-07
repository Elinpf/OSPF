=begin
 This module is set OSPF Opt

=end

module StructFu
module OptSet
	def opt_set(opts)
		if ::String === opts
			opts = [opts]
		end
		opts.each do |opt|	
			unless self.flags.include? opt.downcase
				raise ArgumentError, "Error Flag #{opt}"
			end
			self.send("#{opt.downcase}_set".to_sym)
		end
	end

	def opt_unset(opts)
		if ::String === opts
			opts = [opts]
		end
		opts.each do |opt|
			unless self.flags.include? opt.downcase
				raise ArgumentError, "Error Flag #{opt}"
			end
			self.send("#{opt.downcase}_unset".to_sym)
		end
	end

	def readable
		res = []
		self.flags.each do |e|
			res << e.upcase if self.has_set? e
		end
		if res.empty?
			return "Null"
		else
			return res.join(" ")
		end
	end

	def has_set? flag
		flag = flag.downcase
		flags = self.flags
		return false unless flags.include? flag
		index = flags.index(flag)
		if (self.to_i & 2**index) != 0
			return true
		else
			return false
		end
	end

end

=begin
 This module is set OSPF 

 Opt Struct
  0    1   2    3   4    5    6   7    8
  +----+---+----+---+----+----+---+----+
  | DN | O | DC | L | NP | MC | E | MT | 
  +----+---+----+---+----+----+---+----+

  DC :  Demand Circuits
  L  :  The packet contains LLS data
  NP :  NSSA
  MC :  Multicast Capable
  E  :  External Routing Capability
  MT :  Multi-Topology Routing
=end
class Opt < Int8
	include OptSet
        def dc_set;     self.read(self.to_i | 0b00100000); end 
        def dc_unset;   self.read(self.to_i & 0b11011111); end 

        def l_set;      self.read(self.to_i | 0b00010000); end 
        def l_unset;    self.read(self.to_i & 0b11101111); end 

        def np_set;     self.read(self.to_i | 0b00001000); end 
        def np_unset;   self.read(self.to_i & 0b11110111); end 

        def mc_set;     self.read(self.to_i | 0b00000100); end 
        def mc_unset;   self.read(self.to_i & 0b11111011); end 

        def e_set;      self.read(self.to_i | 0b00000010); end 
        def e_unset;    self.read(self.to_i & 0b11111101); end 

        def mt_set;     self.read(self.to_i | 0b00000001); end 
        def mt_unset;   self.read(self.to_i & 0b11111110); end 

	def flags
		%W[mt e mc np l dc o dn]	
	end

end

=begin
  DB Descrption Option Struct
  0       4   5   6   7    8
  +-------+---+---+---+----+
  |.|.|.|.| R | I | M | MS |
  +-------+---+---+---+----+
=end
class DBDOpt < Int8
	include OptSet
        def r_set;     self.read(self.to_i | 0b00001000); end 
        def r_unset;   self.read(self.to_i & 0b11110111); end 

        def i_set;     self.read(self.to_i | 0b00000100); end 
        def i_unset;   self.read(self.to_i & 0b11111011); end 

        def m_set;      self.read(self.to_i | 0b00000010); end 
        def m_unset;    self.read(self.to_i & 0b11111101); end 

        def ms_set;     self.read(self.to_i | 0b00000001); end 
        def ms_unset;   self.read(self.to_i & 0b11111110); end 

	def flags
		%W[ms m i r]
	end
end

=begin
  Router-LSA Option
  0         5   6   7   8
  +-------+-+---+---+---+
  |.|.|.|.|.| V | E | B |
  +-------+-+---+---+---+
=end
class LSAOpt < Int8
	include OptSet
        def v_set;     self.read(self.to_i | 0b00000100); end 
        def v_unset;   self.read(self.to_i & 0b11111011); end 

        def e_set;      self.read(self.to_i | 0b00000010); end 
        def e_unset;    self.read(self.to_i & 0b11111101); end 

        def b_set;     self.read(self.to_i | 0b00000001); end 
        def b_unset;   self.read(self.to_i & 0b11111110); end 

	def flags
		%W[b e v]
	end
end

end # Module



