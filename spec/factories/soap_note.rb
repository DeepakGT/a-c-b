FactoryBot.define do
  factory :soap_note do
    note { 'test-note' }
    add_date { Time.current.to_date }
    creator_id { create(:user, :with_role, role_name: 'super_admin').id }
    scheduling_id { create(:scheduling) }
  end
end
