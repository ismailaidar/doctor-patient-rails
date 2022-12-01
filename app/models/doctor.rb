class Doctor < ApplicationRecord
  belongs_to :person
  has_many :appointments
  self.primary_key = 'person_id'
  enum :status, {
    active: 'active', no_active: 'no_active'
  }, default: 'active', prefix: true
  validates :person, presence: true
  validates :npi, presence: true, length: { is: 10 }, format: { with: /\A[0-9]+\z/, message: 'only allows numbers' },
                  uniqueness: true
end
