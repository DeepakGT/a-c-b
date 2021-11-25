class QualificationsFundingSource < ApplicationRecord
  belongs_to :qualification
  belongs_to :funding_source

  enum type: {required: 0, must_file: 1, is_filed: 2}, prefix: true

  validates :qualification_id, uniqueness: {scope: [:funding_source_id, :type]}
end
