class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true
  belongs_to :service_address_type, optional: true

  enum address_type: { general: 0, insurance_address: 1, service_address: 2 }

  validates :zipcode, length: { is: 5, wrong_length: "must be exact 5 characters long." }, if: :is_country_usa?
  validate :validate_is_hidden_for_default_service_address

  scope :by_service_address, ->{ where(address_type: 'service_address') }

  delegate :name, to: :service_address_type, prefix: true

  private

  def is_country_usa?
    country == 'United States of America'
  end

  def validate_is_hidden_for_default_service_address
    if self.service_address? && self.is_default.to_bool.true? && self.is_hidden.to_bool.true?
      errors.add(:is_hidden, 'cannot be true for default address.')
    end
  end
end
