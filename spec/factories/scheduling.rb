FactoryBot.define do
  factory :scheduling do
    client_id { create(:client).id }
    staff_id {create(:staff, :with_role, role_name: 'bcba').id}
    service_id {create(:service).id}
    status { 'scheduled' }
    date { Time.now.to_date }
    start_time { DateTime.now+0.1 }
    end_time { DateTime.now+0.3 }
  end
end
