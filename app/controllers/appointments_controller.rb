class AppointmentsController < ApplicationController
  before_action :set_appointment, only: %i[show edit update destroy]
  before_action :set_patients, only: %i[new create edit update]

  def index
    @appointments = Appointment
                    .includes(patient: :person, doctor: :person)
                    .order(id: :DESC)
                    .paginate(page: params[:page], per_page: 10)
  end

  def show; end

  def new
    @appointment = Appointment.new
    @doctors = Doctor.active_doctors
  end

  def edit
    @doctors = Doctor.active_doctors([@appointment.patient.doctor_id])
  end

  def create
    @appointment = Appointment.new(appointment_params)
    if @appointment.commit
      redirect_to @appointment, notice: 'Appointment was successfully created.'
    else
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
    params.require(:appointment).slice(:patient_id, :doctor_id,
                                       :timerange).merge(timerange:).permit!
  end
end
