class DoctorsController < ApplicationController
  before_action :set_doctor, only: %i[show edit update destroy]
  before_action :set_unassigned_people_and_status
  def index
    @doctors = Doctor.includes(:person).order('person_id DESC')
  end

  def show; end

  def new
    @doctor = Doctor.new
  end

  def create
    @doctor = Doctor.new(doctor_params)
    if @doctor.commit
      redirect_to doctor_url(@doctor), notice: 'Doctor was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    old_status = @doctor.status
    @doctor.assign_attributes({
                                npi: doctor_params[:npi],
                                status: doctor_params[:status]
                              })
    Doctor.transaction do
      if @doctor.commit
        if old_status != 'active' && @doctor.status_active?
          @doctor.appointments.update_all(status: :ok)
        elsif old_status == 'active' && @doctor.status_active? == false
          @doctor.appointments.update_all(status: :error)
        end
        redirect_to doctor_url(@doctor), notice: 'Doctor was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::ActiveRecordError
    redirect_to doctor_url(@doctor), alert: "something's wrong"
  end

  def destroy
    @doctor.destroy
    redirect_to doctors_url, notice: 'Doctor was successfully destroyed.'
  rescue ActiveRecord::InvalidForeignKey
    redirect_to doctor_url(@doctor), alert: 'The doctor has appointments or patients that you must delete before.'
  rescue ActiveRecord::ActiveRecordError
    redirect_to doctor_url(@doctor), alert: "something's wrong"
  end

  private

  def set_doctor
    @doctor = Doctor.includes(:person).find_by_person_id(params[:id])
  end

  def doctor_params
    params.require(:doctor).permit(:npi, :person_id, :status)
  end

  def set_unassigned_people_and_status
    @people = Person.joins('LEFT OUTER JOIN doctors ON doctors.person_id = people.id')
                    .where('doctors.person_id IS null')
                    .order(:id)
    @statuses = Doctor.statuses.map { |v, k| [v, k.split('_').join(' ')] }
  end
end
