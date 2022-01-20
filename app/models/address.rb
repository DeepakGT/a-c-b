class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true, inverse_of: :addressable

  enum address_type: { general: 0, insurance_address: 1, service_address: 2}
end
