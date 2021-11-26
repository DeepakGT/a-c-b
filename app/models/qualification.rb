class Qualification < ApplicationRecord
  belongs_to :staff, class_name: :User

  has_many :qualifications_credentials, dependent: :destroy
  has_many :credentials, through: :qualifications_credentials

  accepts_nested_attributes_for :qualifications_credentials, :allow_destroy => true

end
