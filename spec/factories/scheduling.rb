FactoryBot.define do
  factory :scheduling do
    client_enrollment_service_id { create(:client_enrollment_service).id }
    staff_id {create(:staff, :with_role, role_name: 'client_care_coordinator').id}
    status { 'scheduled' }
    date { '2876-07-15' }
    start_time { (DateTime.current+0.1).strftime('%H:%M') }
    end_time { (DateTime.current+0.3).strftime('%H:%M') }
    user { create(:user, :with_role, role_name: 'super_admin') }
    rendered_at { nil }
  end
end
