class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def commit
    save(validate: false)
  rescue ActiveRecord::ActiveRecordError
    valid?
  end
end
