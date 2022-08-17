FactoryBot.define do
  factory :region do
    sequence(:name) { |n| "test-org #{n}" }
  end
end