class DoctorsController < ApplicationController
  before_action :set_doctor, only: %i[show edit update destroy]
  before_action :set_unassigned_people, only: %i[new create edit update]
  before_action :set_statuses, only: %i[edit update]

  def index
    @doctors = Doctor
      .includes(:person)
      .order(person_id: :DESC)
      .paginate(page: params[:page], per_page: 10)
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
    @doctor.assign_attributes(doctor_params)
    Doctor.transaction do
      if @doctor.commit
        if @doctor.status_before_last_save != 'active' && @doctor.status_active?
          @doctor.appointments.update_all(status: :ok)
        elsif @doctor.status_before_last_save == 'active' && !@doctor.status_active?
          @doctor.appointments.update_all(status: :error)
        end
        redirect_to doctor_url(@doctor), notice: 'Doctor was successfully updated.'
      end
    end
  rescue ActiveRecord::StatementInvalid
    render :edit, status: :unprocessable_entity
  rescue ActiveRecord::ActiveRecordError
    redirect_to doctor_url(@doctor), alert: "something's wrong"
  end

  def destroy
    @doctor.delete
    redirect_to doctors_url, notice: 'Doctor was successfully destroyed.'
  rescue ActiveRecord::ActiveRecordError
    redirect_to doctor_url(@doctor), alert: "something's wrong"
  end

  private

  def set_doctor
    @doctor = Doctor.includes(:person).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to doctors_url, alert: 'Doctor not found'
  end

  def doctor_params
    params.require(:doctor).permit(:npi, :person_id, :status)
  end

  def set_unassigned_people
    @people = Person.joins('LEFT OUTER JOIN doctors ON doctors.person_id = people.id')
                    .where('doctors.person_id IS null or doctors.person_id = ? ', @doctor&.person_id)
                    .order(:id)
  end

  def set_statuses
    @statuses = Doctor.statuses
  end
end
