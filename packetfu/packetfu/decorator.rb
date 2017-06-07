module Decorator
	def add_base dec
		@dec = dec
	end

	def method_missing(method, *args)
		@dec.send(method.to_sym, *args)
	end
end
