class ClientNote < ApplicationRecord
  belongs_to :client, optional: true

  validates_presence_of :note

  scope :by_client_id, ->(client_id){ where(client_id: client_id) }
end
