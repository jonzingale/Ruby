class Polynomial

	def initialize(monomial=[]) ; @xs = monomial ; end

	def to_a ; @xs ; end

	def *(it)
		hash = {}

		@xs.to_a.each_with_index do |a,i| 
			it.to_a.each_with_index do |b,j|
				hash[i+j] = (hash[i+j].nil? ? 0 : hash[i+j]) + b*a
			end
		end

		self.class.new(hash.values)
	end
end