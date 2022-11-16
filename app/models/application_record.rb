class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def commit(params = nil)
    save(validate: false)
  rescue ActiveRecord::ActiveRecordError 
    valid?
  end
end
