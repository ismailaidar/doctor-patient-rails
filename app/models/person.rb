class Person < ApplicationRecord

	def full_name
			"#{first_name} #{last_name}"
	end
	validates :first_name, :last_name,  presence: true

end
