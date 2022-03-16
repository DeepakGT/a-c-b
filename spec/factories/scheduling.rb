FactoryBot.define do
  factory :scheduling do
    client_enrollment_service_id { create(:client_enrollment_service).id }
    staff_id {create(:staff, :with_role, role_name: 'bcba').id}
    status { 'scheduled' }
    date { Time.now.to_date }
    start_time { DateTime.now+0.1 }
    end_time { DateTime.now+0.3 }
  end
end
