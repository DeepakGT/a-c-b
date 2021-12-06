FactoryBot.define do
  factory :clinic do
    name {Faker::Address.street_name}
    organization_id {create(:organization, name: Faker::Lorem.word).id}
  end
end
