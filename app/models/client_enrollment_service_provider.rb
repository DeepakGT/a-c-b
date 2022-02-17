class ClientEnrollmentServiceProvider < ApplicationRecord
  belongs_to :client_enrollment_service
  belongs_to :staff
end
