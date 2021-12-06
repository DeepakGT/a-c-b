FactoryBot.define do
  factory :organization do
    admin_id {create(:user, :with_role, role_name: 'aba_admin').id}
  end
end
