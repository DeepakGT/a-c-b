FactoryBot.define do
  factory :user do
    sequence :email do |n|
      "testuser#{n}@yopmail.com"
    end

    password { 'Abcd@123' }

    transient do
      role_name {'executive_director'}
    end

    trait :with_role do 
      after(:build) do |user, evaluator|
        role = Role.find_by(name: evaluator.role_name) || create(:role, name: evaluator.role_name)
        user.role = role
      end
    end
  end
end
