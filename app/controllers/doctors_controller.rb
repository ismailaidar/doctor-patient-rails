class DoctorsController < ApplicationController
  before_action :set_doctor, only: %i[ show edit update destroy ]

  include RetireLeave
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
    if @doctor.commit
      redirect_to doctor_url(@doctor), notice: "Doctor was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @doctor.destroy
    redirect_to doctors_url, notice: "Doctor was successfully destroyed."
  rescue ActiveRecord::ActiveRecordError
    redirect_to doctors_url, alert: "The doctor has many appointments or patients that you must delete before."
  end

  def retire_leave
    @doctor = Doctor.includes(:person).find(params[:id])
    action = params[:retire_leave]
    status = get_status_msg(action) 
    if status[:error] == true
      redirect_to doctor_url(@doctor), alert: status[:msg]
    end
    @doctor.update(status: status[:index])
    @doctor.appointments.update_all(status: :error)
    redirect_to doctor_url(@doctor), notice: status[:msg]
  end

  

  private
  def set_doctor
    @doctor = Doctor.includes(:person).find(params[:id])
  end

  def doctor_params
    params.require(:doctor).permit(:npi, person_attributes: [:id ,:first_name, :last_name] )
  end
end
