FactoryBot.define do
  factory :notification do
    transient do
      recipient { nil }
    end

    recipient_id { recipient.id }
    recipient_type { recipient.class.name }
  end
end
