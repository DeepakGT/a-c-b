FactoryBot.define do
  factory :client_enrollment do
    client_id { create(:client).id }
    funding_source_id { create(:funding_source).id }
    is_primary { false }
    insurance_id { 'UXY56773' }
    source_of_payment { 'insurance' }
    terminated_on { '2033-04-30' }
  end
end
