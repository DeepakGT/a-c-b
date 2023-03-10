class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true
  belongs_to :service_address_type, optional: true

  enum address_type: { general: 0, insurance_address: 1, service_address: 2 }

  validates :zipcode, length: { is: 5, wrong_length: "must be exact 5 characters long." }, if: :is_country_usa?
  validate :validate_is_hidden_for_default_service_address
  validates :service_address_type_id, presence: true, if: proc { |a| a.address_type == 'service_address' }
  validate :select_service_address_type

  scope :by_service_address, ->{ where(address_type: 'service_address') }

  def full_address
    "#{try(:service_address_type).try(:name)} - #{try(:line1)} "
  end

  private

  def select_service_address_type
    return true unless service_address?
    return true if service_address_type.present? && service_address_type.name != Constant.n_a

    errors.add(:service_address_type_id, I18n.t('.application_controller.controllers.address.error_type'))
  end

  def is_country_usa?
    country == 'United States of America'
  end

  def validate_is_hidden_for_default_service_address
    if self.service_address? && self.is_default.to_bool.true? && self.is_hidden.to_bool.true?
      errors.add(:is_hidden, 'cannot be true for default address.')
    end
  end
end
