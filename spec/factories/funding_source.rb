FactoryBot.define do
  factory :funding_source do
    name {Faker::Lorem.word}
    clinic_id {create(:clinic, name: Faker::Lorem.word).id}
  end
end
