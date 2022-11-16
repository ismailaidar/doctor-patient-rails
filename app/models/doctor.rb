class Doctor < ApplicationRecord
	belongs_to :person
	accepts_nested_attributes_for :person, allow_destroy: true

	validates :npi, presence: true, length: { is: 10}, format: { with: /\A[0-9]+\z/,
			message: "only allows numbers" }, uniqueness: true
	
	
end
  