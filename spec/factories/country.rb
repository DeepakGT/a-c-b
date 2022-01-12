FactoryBot.define do
  factory :country do
    name {Faker::Lorem.word}
  end
end