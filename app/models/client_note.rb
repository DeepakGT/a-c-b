class ClientNote < ApplicationRecord
  belongs_to :client, optional: true

  validates_presence_of :note
end
