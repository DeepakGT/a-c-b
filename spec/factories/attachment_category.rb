FactoryBot.define do
  factory :attachment_category do
    sequence(:name) { |n| "test-cat #{n}" }
  end
end
