FactoryBot.define do
  factory :client_note do
    association :client
    note { Faker::Address.community }
    add_date { Date.today }
  end
end
