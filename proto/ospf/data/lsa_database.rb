=begin
LSA Database Struct
checksum => LSAPacket
Class:
Int16 => LSAPacket

=end
class LSADatabase
	include Singleton
	def initialize
		@@db = Hash.new
	end

	def add lsa
		cksum = lsa.ospf_lsa_cksum
		@@db[cksum] = lsa
	end

	def << lsa
		self.add lsa
	end

	def find cksum
		@@db.has_key? cksum
	end

	def get cksum
		return "Not find this lsa" unless self.find cksum
		@@db[cksum]
	end

	def get_lsa lsa
		cksum = lsa.ospf_lsa_cksum
		self.get cksum
	end

	def get_by_lsr lsr
		@@db.select do |cksum, lsa|
			unless lsa.ospf_lsa_lstype == lsr.ospf_lstype
				return false
			end
			unless lsa.ospf_lsa_lsid == lsr.ospf_lsid
				return false
			end
			unless lsa.ospf_lsa_ar == lsr.ospf_ar
				return false
			end
			return true
		end
	end

	def remove cksum
		@@db.delete cksum
	end

	def remove_lsa lsa
		cksum = lsa.ospf_lsa_cksum
		self.remove cksum
	end
end

		


