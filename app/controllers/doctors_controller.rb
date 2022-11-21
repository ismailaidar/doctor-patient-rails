class DoctorsController < ApplicationController
  before_action :set_doctor, only: %i[show edit update destroy]

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
    @doctor.assign_attributes({
                                npi: doctor_params[:npi],
                                person_id: doctor_params[:person_id],
                                status: doctor_params[:status]
                              })
    if @doctor.commit
      redirect_to doctor_url(@doctor), notice: 'Doctor was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @doctor.destroy
    redirect_to doctors_url, notice: 'Doctor was successfully destroyed.'
  rescue ActiveRecord::ActiveRecordError
    redirect_to doctors_url, alert: 'The doctor has appointments or patients that you must delete before.'
  end

  private

  def set_doctor
    @doctor = Doctor.includes(:person).find(params[:id])
  end

  def doctor_params
    params.require(:doctor).permit(:npi, :person_id, :status)
  end
end
