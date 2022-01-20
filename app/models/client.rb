class Client < User
  has_many :contacts, dependent: :destroy
  has_many :addresses, as: :addressable, dependent: :destroy
  has_one :phone_number, as: :phoneable, dependent: :destroy
  has_many :client_enrollments, dependent: :destroy
  has_many :funding_sources, through: :client_enrollments

  accepts_nested_attributes_for :addresses, update_only: true
  accepts_nested_attributes_for :phone_number, update_only: true
end
