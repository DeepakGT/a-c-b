FactoryBot.define do
  factory :attachment_category do
    sequence(:name) { |n| "test_cat #{n}" }
  end
end
