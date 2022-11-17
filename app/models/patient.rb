class Patient < ApplicationRecord
	belongs_to :person
	belongs_to :doctor,  optional: true
	validates :upi, presence: true
end
