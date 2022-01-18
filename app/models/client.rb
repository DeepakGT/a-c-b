class Client < User
  has_many :contacts, dependent: :destroy
  has_many :addresses, as: :addressable, dependent: :destroy
  has_one :phone_number, as: :phoneable, dependent: :destroy

  accepts_nested_attributes_for :addresses, update_only: true
  accepts_nested_attributes_for :phone_number, update_only: true

  enum payer_status: {active: 0, on_hold: 1, pending_authorization: 2, waitlist: 3}
end
