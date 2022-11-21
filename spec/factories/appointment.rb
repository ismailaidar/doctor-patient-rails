FactoryBot.define do
  factory :appointment do
    doctor_id { '1234567891' }
    patient_id { -1 }
    timerange { '[2022-11-11T09:32, 2022-11-11T10:32)' }
  end
end
