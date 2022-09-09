FactoryBot.define do
  factory :client_enrollment_service do
    association :client_enrollment
    start_date { Date.today }
    end_date { Date.today + 1.year }
    client_enrollment_id { create(:client_enrollment, terminated_on: '2022-04-30').id }
    service_id { create(:service).id }
    units {rand(100..1000)}
    minutes {rand(100..1000) * 15}
    service_number {rand(0..1000)}
  end
end
