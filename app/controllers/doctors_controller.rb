class DoctorsController < ApplicationController
  before_action :set_doctor, only: %i[ show edit update  ]
  def index
    @doctors = Doctor.order("person_id DESC")
  end

  def show
  end

  def new
    @doctor = Doctor.new
    @doctor.build_person 
  end

  def create
    @doctor = Doctor.new(doctor_params)
    @doctor.build_person doctor_params[:person_attributes]
    if @doctor.commit
      redirect_to doctor_url(@doctor), notice: "Doctor was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  
  end

  def edit
  end

  private
  def set_doctor
    @doctor = Doctor.find(params[:id])
  end

  def doctor_params
    params.require(:doctor).permit(:npi, person_attributes: [:first_name, :last_name] )
  end
end
