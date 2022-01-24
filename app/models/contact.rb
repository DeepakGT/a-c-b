class Contact < ApplicationRecord
  # associations
  belongs_to :client

  has_one :address, as: :addressable, dependent: :destroy
  has_many :phone_numbers, as: :phoneable, dependent: :destroy

  accepts_nested_attributes_for :address, update_only: true
  accepts_nested_attributes_for :phone_numbers, update_only: true

  # enums
  enum relation_type: { self: 0,parent_or_guardian: 1, spouse_or_partner: 2, lci_or_foster_home: 3, 
                        external_contact: 4, internal_contact: 5 }, _prefix: true
  enum relation: { self: 0, mother: 1, father: 2, partner: 3, child: 4, friend: 5, sibling: 6,
                   referent: 7, sponsor: 8, therapist: 9, case_manager: 10, probation_officer: 11,
                   other_relative: 12, bd: 13, child_care: 14, emergency_contact: 15, service_coordinator: 16}, _prefix: true

  # validations
  validates_uniqueness_of :email
  validates_inclusion_of :parent_portal_access, in: [ true, false ], message: "must be present.", 
    if: ->{ self.parent_or_guardian? }
  validates_exclusion_of :parent_portal_access, in: [ true, false ], message: "must not be present.", 
    if: ->{ !self.parent_or_guardian? }

  private

  def parent_or_guardian?
    self.relation_type == "parent_or_guardian"
  end
end
