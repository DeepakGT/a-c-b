FactoryBot.define do
  factory :client_enrollment_payment do
    association :client
    association :funding_source
    insurance_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    source_of_payment {'insurance'}
  end
end
