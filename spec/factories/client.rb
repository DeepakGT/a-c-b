FactoryBot.define do
  factory :client do
    association :clinic
    sequence :email do |n|
      "testclient#{n}@yopmail.com"
    end

    payor_status { 'insurance' }
    first_name {Faker::Name.name}
    last_name {Faker::Name.name}
  end
end
