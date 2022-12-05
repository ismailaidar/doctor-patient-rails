FactoryBot.define do
  factory :doctor do
    npi { Faker::Number.leading_zero_number(digits: 10) }
    :person
    status { 'active' }
  end
end
