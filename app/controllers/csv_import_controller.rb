require 'csv'

class CsvImportController < ApplicationController
  def index; end

  def upload
    report = UploadCsv.import(params.require(:file).read)
    redirect_to csv_import_index_path,
                notice: 'Number of doctor, patient, relationship, and appointment records created: '
  end
end
