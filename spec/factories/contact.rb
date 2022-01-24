FactoryBot.define do
  factory :contact do
    association :client
    sequence :email do |n|
      "testcontact#{n}@yopmail.com"
    end

    first_name {Faker::Name.name}
  end
end
