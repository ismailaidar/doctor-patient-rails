class Appointment < ApplicationRecord
  belongs_to :doctor
  belongs_to :patient

  enum :status, {
    ok: 'ok', error: 'error'
  }, default: 'ok'

  validates :timerange, presence: true
  validate :end_date_cannot_be_less_than_start_date
  validate :start_date_cannot_equal_end_date
  validate :timerange_exclude_no_overlap_for_doctor
  validate :timerange_exclude_no_overlap_for_patient
  validate :check_if_dr_and_patient_are_different

  def check_if_dr_and_patient_are_different
    return unless doctor_id && patient_id

    errors.add(:base, 'doctor and patient cannot be the same person') if doctor_id == patient_id
  end

  def start_date_cannot_equal_end_date
    return unless timerange && timerange.first == timerange.last

    errors.add(:base, 'start_date and end_date cannot be equal')
  end

  def timerange_exclude_no_overlap_for_doctor
    return unless timerange && doctor_id
    return if timerange.last < timerange.first

    unless Appointment.ok.where(doctor_id:).where.not(id:).where('timerange && ?',
                                                                 self.class.connection.type_cast(timerange)).empty?
      errors.add(:base,
                 'Appointment time overlaps for the doctor.')
    end
  end

  def timerange_exclude_no_overlap_for_patient
    return unless timerange && patient_id
    return if timerange.last < timerange.first

    unless Appointment.ok.where(patient_id:).where.not(id:).where('timerange && ?',
                                                                  self.class.connection.type_cast(timerange)).empty?
      errors.add(:base, 'Appointment time overlaps for the patient.')
    end
  end

  def end_date_cannot_be_less_than_start_date
    return unless timerange && timerange.last < timerange.first

    errors.add(:end_date, "can't be less than start date")
  end
end
