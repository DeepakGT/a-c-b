class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  enum address_type: { general: 0, insurance_address: 1, service_address: 2}

  validates :zipcode, length: { is: 5, wrong_length: "must be exact 5 characters long." }, if: :is_country_usa?

  scope :by_service_address, ->{where(address_type: 'service_address')}

  private

  def is_country_usa?
    country == 'United States of America'
  end
end
