FactoryBot.define do
  factory :staff_qualification do
    staff_id { create(:user, :with_role, role_name: 'rbt').id }
    credential_id { create(:qualification, name: Faker::Lorem.word).id }
  end
end
