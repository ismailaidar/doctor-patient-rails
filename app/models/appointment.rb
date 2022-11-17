class Appointment < ApplicationRecord
	belongs_to :doctor
	enum :status, { good: 0, error: 1 }
end
  