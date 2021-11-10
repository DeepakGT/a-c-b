FactoryBot.define do
  factory :user do
    sequence :email do |n|
      "#{Faker::Internet.email}"
    end

    password { '123456' }
  end
end
