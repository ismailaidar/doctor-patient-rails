class Doctor < ApplicationRecord
	belongs_to :person
	accepts_nested_attributes_for :person, allow_destroy: true

	validates :npi, presence: true, allow_blank: false, length: { is: 10}, format: { with: /\A[0-9]+\z/,
			message: "only allows numbers" }, uniqueness: true
	validate :first_name_last_name_check_blank

	private
	def first_name_last_name_check_blank
		errors.add( :base, "first name can't be blank" ) if person.first_name == ''
		errors.add( :base, "last name can't be blank" ) if person.last_name == ''
	end
	
end
  