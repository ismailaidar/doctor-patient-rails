class Appointment < ApplicationRecord
  belongs_to :doctor
  belongs_to :patient

  enum :status, {
    ok: 'ok', error: 'error'
  }, default: 'ok'

  attr_accessor :start_date, :end_date

  validates :timerange, presence: true
  validates :start_date, :end_date, presence: true
  validate :end_date_cannot_be_less_than_start_date
  validate :start_date_cannot_equal_end_date
  validate :timerange_exclude_no_overlap_for_doctor
  validate :timerange_exclude_no_overlap_for_patient

  def start_date_cannot_equal_end_date
    return unless timerange

    errors.add(:base, 'start_date cannot equal end_date') if timerange.first == timerange.last
  end

  def timerange_exclude_no_overlap_for_doctor
    return unless timerange || doctor_id

    Appointment.where(doctor_id:).where.not(id:).each do |item|
      errors.add(:base, 'Appointment time overlaps for the doctor.') if timerange&.overlaps?(item.timerange)
    end
  end

  def timerange_exclude_no_overlap_for_patient
    return unless timerange || patient_id

    Appointment.where(patient_id:).where.not(id:).each do |item|
      errors.add(:base, 'Appointment overlaps for the patient.') if timerange.overlaps?(item.timerange)
    end
  end

  def end_date_cannot_be_less_than_start_date
    return unless timerange

    return unless timerange.last < timerange.first

    errors.add(:end_date, "can't be less than start date")
  end
end
