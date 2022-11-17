class Doctor < ApplicationRecord
	belongs_to :person
	has_many :appointments
	enum :status, { active: 0, leave: 1, retire: 2 }
	validates :person, uniqueness: true
	validates :npi, presence: true, length: { is: 10}, format: { with: /\A[0-9]+\z/, message: "only allows numbers" }, uniqueness: true
end
  