FactoryBot.define do
  factory :staff_clinic do
    clinic_id {create(:clinic, name: 'test-clinic').id}
    staff_id {create(:staff, :with_role, role_name: 'bcba').id}
    is_home_clinic {false}
  end
end
