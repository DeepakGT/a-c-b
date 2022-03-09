FactoryBot.define do
  factory :service do
    name {Faker::Lorem.words}
    display_code {'ABcd7645'}
  end
end
