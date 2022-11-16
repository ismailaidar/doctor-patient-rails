class DoctorsController < ApplicationController
  before_action :set_doctor, only: %i[ show edit update destroy ]
  def index
    @doctors = Doctor.includes(:person).order("person_id DESC")
  end

  def show
  end

  def new
    @doctor = Doctor.new
    @doctor.build_person
  end

  def create
    @doctor = Doctor.new(doctor_params)
    
    if @doctor.commit
      redirect_to doctor_url(@doctor), notice: "Doctor was successfully created."
    else
      @doctor.build_person doctor_params[:person_attributes]
      render :new, status: :unprocessable_entity
    end
  
  end

  def edit
  end

  def update
    @doctor.assign_attributes({ npi: doctor_params[:npi], person_attributes:doctor_params[:person_attributes]})
    if @doctor.commit(doctor_params)
      redirect_to doctor_url(@doctor), notice: "Doctor was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @doctor.destroy
    redirect_to doctors_url, notice: "Doctor was successfully destroyed."
  end

  private
  def set_doctor
    @doctor = Doctor.includes(:person).find(params[:id])
  end

  def doctor_params
    params.require(:doctor).permit(:npi, person_attributes: [:id ,:first_name, :last_name] )
  end
end
