require 'csv'

class CsvImportController < ApplicationController
  def index; end

  def upload
    uploaded_file = params[:file]
    File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'w') do |file|
      file.write(uploaded_file.read)
      file_path = Rails.root.join('public', 'uploads', 'import.csv')
      file_path = "#{file_path.dirname}/#{uploaded_file.original_filename}"
      report = UploadCsv.import(file_path)
      csv_count = CSV.foreach(file).count
      redirect_to csv_import_index_path,
                  notice: "Number of doctor, patient, relationship, and appointment records created: #{records_counts}
      Number of invalid appointments: #{(report.cmd_tuples - csv_count) * -1}"
    end
  end

  private

  def records_counts
    nb_doctors = Doctor.where('created_at  >= ?', 5.seconds.ago).count
    nb_patients = Patient.where('created_at  >= ?', 5.seconds.ago).count
    nb_appointments = Appointment.where('created_at  >= ?', 5.seconds.ago).count

    nb_appointments + nb_doctors + nb_patients
  end

  def form_params
    params.permit(:file)
  end
end
