class Person < ApplicationRecord
  has_one :doctor
  has_one :patient

  validates :first_name, :last_name, presence: true
  def full_name
    "#{first_name} #{last_name}"
  end
end
