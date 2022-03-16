class ServiceQualification < ApplicationRecord
  belongs_to :service
  belongs_to :qualification
end
