FactoryBot.define do
  factory :doctor do
    npi { '1234567891' }
    person_id { -1 }
    status { 0 }
  end
end
