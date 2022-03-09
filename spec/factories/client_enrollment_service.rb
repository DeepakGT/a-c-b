FactoryBot.define do
  factory :client_enrollment_service do
    association :client_enrollment
    association :service
    start_date { Date.today }
    end_date { Date.tomorrow }
  end
end
