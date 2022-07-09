FactoryBot.define do
  factory :organization do
    admin_id {create(:user, :with_role, role_name: 'executive_director').id}
  end
end
