class Contact < ApplicationRecord
  belongs_to :client

  has_one :address, as: :addressable, dependent: :destroy
  has_one :phone_number, as: :phoneable, dependent: :destroy

  accepts_nested_attributes_for :address, update_only: true
  accepts_nested_attributes_for :phone_number, update_only: true
end
