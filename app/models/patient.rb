class Patient < ApplicationRecord
  belongs_to :person
  belongs_to :doctor, required: false
  self.primary_key = 'person_id'
  validates :upi, presence: true, length: { is: 18 },
                  format: { with: /\A[a-z0-9]+\z/, message: 'only allows Alphanumeric' },
                  uniqueness: true
end
