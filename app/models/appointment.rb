class Appointment < ApplicationRecord
  belongs_to :doctor
  enum :status, {
    ok: 'ok', error: 'error'
  }, default: 'ok'
end
