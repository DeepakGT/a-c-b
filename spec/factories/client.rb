FactoryBot.define do
  factory :client do
    association :clinic
    sequence :email do |n|
      "testclient#{n}@yopmail.com"
    end

    password { 'Abcd@123' }

    transient do
      role_name {'client'}
    end

    trait :with_role do 
      after(:build) do |client, evaluator|
        role = Role.find_by(name: evaluator.role_name) || create(:role, name: evaluator.role_name)
        client.role = role
      end
    end
  end
end
