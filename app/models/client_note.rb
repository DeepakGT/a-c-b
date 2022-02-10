class ClientNote < ApplicationRecord
  belongs_to :client, optional: true

  has_many :attachments, as: :attachable

  accepts_nested_attributes_for :attachments
end
