class Patient < ApplicationRecord
    belongs_to :person
    belongs_to :doctor,  optional: true
    # accepts_nested_attributes_for :person, allow_destroy: true
    
    validates :upi, presence: true
end
