class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true, inverse_of: :addressable

  enum address_type: { general: 0, insurance_address: 1, service_address: 2}

  validates_length_of :zipcode, is: 5, if: :is_country_usa?

  private

  def is_country_usa?
    country == 'United States of America'
  end
end
