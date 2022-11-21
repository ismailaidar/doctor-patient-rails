class Doctor < ApplicationRecord
  belongs_to :person
  has_many :appointments
  enum :status, {
    active: 'active', leaved: 'leaved', retired: 'retired'
  }, default: 'active', prefix: true
  validates :person, uniqueness: true
  validates :npi, presence: true, length: { is: 10 }, format: { with: /\A[0-9]+\z/, message: 'only allows numbers' },
                  uniqueness: true
end
