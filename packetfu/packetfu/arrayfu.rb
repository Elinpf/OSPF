=begin
 This ArrayFu is in StructFu module
 Is use for Array Struct
 How to Use
 
 ArrayFu.new.read(["\x11\x12\x13\x14"])

 :Note:
   Must use nil not []

Use in lsa_router.rb  lsa_network.rb
=end


module StructFu

	class ArrayFu < Array
		# This to_s is like self.each {|e| e.to_s}.join
		def to_s
			res = ""
			self.each do |e|
				begin 
					res << e.to_s
				rescue
					next
				end
			end
			res
		end

		# read ??!!!!
		def read args
			return self if args.nil?
			if Array === args
				args.each do |arg|
					self << arg
				end
			else
				p args.class
			end
			self
		end
	end
end
		
