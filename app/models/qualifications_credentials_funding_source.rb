class QualificationsCredentialsFundingSource < ApplicationRecord
  belongs_to :qualifications_credential
  belongs_to :funding_source

  enum funding_source_type: {required: 0, must_file: 1, is_filed: 2}

  validates :qualifications_credential_id, uniqueness: {scope: [:funding_source_id, :type]}
end
