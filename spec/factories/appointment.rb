FactoryBot.define do
  factory :appointment do
    doctor
    patient
    timerange do
      start = Faker::Time.between(from: 1.year.ago, to: Time.now)
      stop = Faker::Time.between(from: start, to: start + 3.hours)
      start...stop
    end
  end
end
