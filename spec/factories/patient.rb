FactoryBot.define do
  factory :patient do
    sequence(:upi) { |n| '%018x' % n }
    person
  end
end
