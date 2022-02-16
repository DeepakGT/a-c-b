FactoryBot.define do
  factory :client do
    association :clinic
    sequence :email do |n|
      "testclient#{n}@yopmail.com"
    end

    password { 'Abcd@123' }
    payor_status { 'insurance' }
  end
end
