class ClientNote < ApplicationRecord
  belongs_to :client, optional: true

  has_one :attachment, as: :attachable

  accepts_nested_attributes_for :attachment, update_only: true
end
