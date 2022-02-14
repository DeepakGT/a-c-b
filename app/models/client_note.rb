class ClientNote < ApplicationRecord
  belongs_to :client, optional: true
end
