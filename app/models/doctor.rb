class Doctor < ApplicationRecord
	belongs_to :person
	has_many :appointments
	accepts_nested_attributes_for :person, allow_destroy: true
	enum :status, { active: 0, leave: 1, retire: 2 }

	validates :npi, presence: true, length: { is: 10}, format: { with: /\A[0-9]+\z/,
			message: "only allows numbers" }, uniqueness: true
	
	
end
  