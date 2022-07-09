FactoryBot.define do
  factory :staff do
    sequence :email do |n|
      "teststaff#{n}@yopmail.com"
    end

    password { 'Abcd@123' }

    transient do
      role_name { 'client_care_coordinator' }
    end

    trait :with_role do
      after(:build) do |staff,evaluator|
        role = Role.find_by(name: evaluator.role_name) || create(:role, name: evaluator.role_name)
        staff.role = role
      end
    end
  end
end
