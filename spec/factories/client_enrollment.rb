FactoryBot.define do
  factory :client_enrollment do
    association :client
    association :funding_source
    is_primary { false }
    insurance_id { 'UXY56773' }
    source_of_payment { 'insurance' }
  end
end
