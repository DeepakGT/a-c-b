FactoryBot.define do
  factory :client_enrollment do
    association :client
    association :funding_source
    enrollment_date { Date.new }
    insureds_name { Faker::Name.name }
  end
end