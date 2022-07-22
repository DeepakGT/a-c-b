FactoryBot.define do
  factory :client_enrollment_service do
    association :client_enrollment
    start_date { Date.today }
    end_date { Date.tomorrow }
    client_enrollment_id { create(:client_enrollment, terminated_on: '2022-04-30').id }
    service_id { create(:service).id }
  end
end
