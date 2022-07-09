FactoryBot.define do
  factory :service_qualification do
    qualification_id { create(:qualification, name: Faker::Lorem.word).id }
    service_id { create(:service).id }
  end
end
