class AppointmentsController < ApplicationController
  before_action :set_appointment, only: %i[show edit update destroy]
  before_action :set_patients, only: %i[new create edit update]

  def index
    @appointments = Appointment.includes(patient: :person, doctor: :person).order(id: :DESC)
  end

  def show; end

  def new
    @appointment = Appointment.new
    @appointment.start_date = Time.now
    @appointment.end_date = Time.now
    @doctors = Doctor.active_doctors
  end

  def edit
    @doctors = Doctor.active_doctors([@appointment.patient.doctor_id])
    @appointment.start_date = @appointment.timerange.first
    @appointment.end_date = @appointment.timerange.last
  end

  def create
    @appointment = Appointment.new(appointment_params)
    if @appointment.commit
      redirect_to @appointment, notice: 'Appointment was successfully created.'
    else
      @appointment.start_date = @appointment.timerange&.first
      @appointment.end_date = @appointment.timerange&.last
      @doctors = Doctor.active_doctors
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @appointment.assign_attributes(appointment_params)
    if @appointment.commit
      redirect_to @appointment, notice: 'Appointment was successfully updated.'
    else
      @doctors = Doctor.active_doctors([[@appointment.patient&.doctor_id]])
      @appointment.start_date = @appointment.timerange&.first
      @appointment.end_date = @appointment.timerange&.last
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @appointment.delete
    redirect_to appointments_url, notice: 'Appointment was successfully destroyed.'
  rescue ActiveRecord::ActiveRecordError
    redirect_to appointment_url(@appointment), alert: "something's wrong"
  end

  private

  def set_appointment
    @appointment = Appointment.includes(patient: :person, doctor: :person).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to appointments_url, alert: 'Appointment not found'
  end

  def set_patients
    @patients = Patient.includes(:person).all
  end

  def appointment_params
    start_date = params[:appointment][:start_date]&.to_datetime
    end_date = params[:appointment][:end_date]&.to_datetime
    timerange = start_date...end_date if start_date && end_date
    params.require(:appointment).permit(:patient_id, :doctor_id, :timerange, :start_date,
                                        :end_date).merge(timerange:)
  end
end
