class Doctor < ApplicationRecord
  belongs_to :person
  has_many :appointments
  enum :status, {
    active: 'active', on_leave: 'on_leave', retired: 'retired'
  }, default: 'active', prefix: true
  validates :person, uniqueness: true, presence: true
  validates :npi, presence: true, length: { is: 10 }, format: { with: /\A[0-9]+\z/, message: 'only allows numbers' },
                  uniqueness: true
  validate :check_status

  def check_status
    errors.add(:status, 'You must choose a valid status') unless %w[active on_leave
                                                                    retired].include?(status)
  end

  def full_name_status_str
    "#{person.full_name} #{get_status unless status_active?}"
  end

  def get_status
    status.split('_').join(' ')
  end
end
