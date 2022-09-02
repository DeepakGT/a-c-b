FactoryBot.define do
  factory :service_address_type do
    name {Faker::Name.unique.name}
    tag_num {rand(0..1000)}
  end
end
