class PatientsController < ApplicationController
  before_action :set_patient, only: %i[show edit update destroy]
  before_action :set_unassigned_people, only: %i[new create edit update]

  def index
    @patients = Patient.includes(:person, doctor: :person).order(person_id: :DESC)
  end

  def show; end

  def new
    @patient = Patient.new
    @doctors = Doctor.active_doctors
  end

  def edit
    @doctors = Doctor.active_doctors([@patient.doctor_id])
  end

  def create
    @patient = Patient.new(patient_params)
    if @patient.commit
      redirect_to @patient, notice: 'Patient was successfully created.'
    else
      @doctors = Doctor.active_doctors
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @patient.assign_attributes(patient_params)
    if @patient.commit
      redirect_to @patient, notice: 'Patient was successfully updated.'
    else
      @doctors = Doctor.active_doctors([@patient.doctor_id])
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @patient.destroy
    redirect_to patients_url, notice: 'Patient was successfully destroyed.'
  rescue ActiveRecord::InvalidForeignKey
    redirect_to patient_url(@patient), alert: 'This Patient has appointments associated with it.'
  rescue ActiveRecord::ActiveRecordError
    redirect_to patient_url(@patient), alert: "something's wrong"
  end

  private

  def set_patient
    @patient = Patient.includes(:person, doctor: :person).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to patients_url, alert: 'Patient not found'
  end

  def patient_params
    params[:patient][:upi] = params[:patient][:upi].downcase
    params.require(:patient).permit(:upi, :person_id, :doctor_id)
  end

  def set_unassigned_people
    @people = Person.joins('LEFT OUTER JOIN patients ON patients.person_id = people.id')
                    .where('patients.person_id IS null or patients.person_id = ? ', @patient&.person_id)
                    .order(:id)
  end
end
