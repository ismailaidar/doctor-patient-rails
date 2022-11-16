class Doctor < ApplicationRecord
	belongs_to :person
	accepts_nested_attributes_for :person, allow_destroy: true

	validates :npi, presence: true, allow_blank: false, length: { is: 10}, format: { with: /\A[0-9]+\z/,
			message: "only allows numbers" }, uniqueness: true

	def full_name
			"#{self.person.first_name} #{self.person.last_name}"
	end
end
  