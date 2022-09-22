FactoryBot.define do
  factory :region do
    sequence(:name) { |n| "test-region #{n}" }
  end
end
