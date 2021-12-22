FactoryBot.define do
  factory :staff_credential do
    staff_id { create(:user, :with_role, role_name: 'rbt').id }
    credential_id { create(:credential, name: Faker::Lorem.word).id }
  end
end
