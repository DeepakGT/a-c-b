FactoryBot.define do
  factory :client do
    association :clinic
    sequence :email do |n|
      "testclient#{n}@yopmail.com"
    end

    payor_status { 'insurance' }
  end
end
