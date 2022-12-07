class Patient < ApplicationRecord
  belongs_to :person
  belongs_to :doctor, optional: true
  self.primary_key = 'person_id'
  validates :upi, presence: true, length: { is: 18 },
                  format: { with: /\A[a-z0-9]+\z/, message: 'only allows Alphanumeric' },
                  uniqueness: true
  validate :check_if_dr_and_pr_are_diff
  validate :check_if_active_doctor

  private

  def check_if_dr_and_pr_are_diff
    return unless doctor

    errors.add(:base, 'doctor and patient are the same person') if person == doctor.person
  end

  def check_if_active_doctor
    return unless doctor

    # need to be added to PG
    errors.add(:base, 'this doctor is inactive.') if !doctor.status_active? && doctor_changed?
  end
end
