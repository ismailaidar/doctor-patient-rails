class Patient < ApplicationRecord
  belongs_to :person
  belongs_to :doctor
  validates :upi, presence: true, length: { is: 18 },
                  format: { with: /\A[A-Za-z0-9]+\z/, message: 'only allows Alphanumeric' },
                  uniqueness: true
end
