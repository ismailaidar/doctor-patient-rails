require 'csv'

class CsvImportController < ApplicationController
  def index
    return unless session[:invalid_appointments_ids]

    @invalid_appointments = Appointment.includes(doctor: :person, patient: :person)
                                       .where(id: session[:invalid_appointments_ids])
                                       .paginate(page: params[:page], per_page: 10)
  end

  def upload
    report = UploadCsv.import(params.require(:file).read)
    invalid_appointments = report[:appointments].to_a.select { |a| a['status'] == 'error' }
    flash[:notice] = "#{report[:people].cmd_tuples} Doctor,
                      #{report[:patients].cmd_tuples} Patient, and
                      #{report[:appointments].cmd_tuples} Appointment records were created. \n
                      Number of invalid appointments: #{invalid_appointments.count}"

    session.delete(:invalid_appointments_ids)
    session[:invalid_appointments_ids] = invalid_appointments.map { |item| item['id'] }

    redirect_to csv_import_index_path
  end
end
