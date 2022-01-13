class Contact < ApplicationRecord
  has_many :client_contacts, dependent: :destroy
  has_many :clients, through: :client_contacts

  has_one :address, as: :addressable, dependent: :destroy
  has_one :phone_number, as: :phoneable, dependent: :destroy

  accepts_nested_attributes_for :address, update_only: true
  accepts_nested_attributes_for :phone_number, update_only: true
end
