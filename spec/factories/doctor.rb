FactoryBot.define do
  factory :doctor do
    sequence(:npi) { |n| '%010d' % n }
    person
    status { 'active' }
  end
end
