FactoryBot.define do
  factory :patient do
    upi { Faker::Alphanumeric.alphanumeric(number: 18) }
    :person
  end
end
