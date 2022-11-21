FactoryBot.define do
  factory :person do
    id { -1 }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end
end
