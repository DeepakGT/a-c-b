FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "test-org #{n}" }
    admin_id {create(:user, :with_role, role_name: 'executive_director').id}
  end
end
