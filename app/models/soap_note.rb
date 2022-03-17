class SoapNote < ApplicationRecord
  belongs_to :scheduling

  scope :by_client, ->(client_id){ joins(scheduling: [{client_enrollment_service: :client_enrollment}]).where('client_enrollments.client_id': client_id) }
end
