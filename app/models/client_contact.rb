class ClientContact < ApplicationRecord
  belongs_to :contact
  belongs_to :client
end
