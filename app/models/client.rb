class Client < User
  has_many :client_contacts, dependent: :destroy
  has_many :contacts, through: :client_contacts

  accepts_nested_attributes_for :contacts, update_only: true
end
