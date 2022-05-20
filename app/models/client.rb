class Client < ApplicationRecord
  has_one :phone_number, as: :phoneable, dependent: :destroy, inverse_of: :phoneable
  has_many :notes, class_name: :ClientNote, dependent: :nullify
  has_many :attachments, as: :attachable, dependent: :destroy

  has_many :contacts, dependent: :destroy
  has_many :addresses, as: :addressable, dependent: :destroy, inverse_of: :addressable
  has_many :client_enrollments, dependent: :destroy
  has_many :funding_sources, through: :client_enrollments
  
  belongs_to :clinic
  belongs_to :bcba, class_name: :User, optional: true

  after_save :set_default_service_address

  accepts_nested_attributes_for :addresses, update_only: true
  accepts_nested_attributes_for :phone_number, update_only: true

  enum status: {active: 0, inactive: 1}
  enum gender: {male: 0, female: 1}
  enum preferred_language: {english: 0, spanish: 1}
  enum dq_reason: { lost_contact: 0, not_clinically_appropriate: 1, insurance_denial: 2, no_longer_interested: 3, 
                    competitor: 4, not_ready_to_move_forward: 5, other: 6}

  validates :dq_reason, presence: true, if: ->{ self.disqualified? }
  validates :dq_reason, absence: true, if: ->{ !self.disqualified? }

  scope :by_clinic, ->(clinic_id){ where(clinic_id: clinic_id) }
  scope :by_bcbas, ->(bcba_ids) { where(bcba_id: bcba_ids) }
  scope :by_staff_id_in_scheduling, ->(staff_id){ joins(client_enrollments: {client_enrollment_services: :schedulings}).where('schedulings.staff_id = ?', staff_id) }
  scope :with_no_authorizations, ->{ left_outer_joins(client_enrollments: :client_enrollment_services).select('clients.*').group('clients.id').having('count(client_enrollment_services.*) = ?',0) }
  scope :active, ->{ where(status: 'active') }

  def save_with_exception_handler
    self.save
  rescue Exception => e
    errors.add(:address_type, "already present.") if e.is_a? ActiveRecord::RecordNotUnique
  end

  def update_with_exception_handler(client_params)
    self.update(client_params)
  rescue Exception => e
    errors.add(:address_type, "already present.") if e.is_a? ActiveRecord::RecordNotUnique
  end

  private

  def set_default_service_address
    client_service_address = self.addresses.by_service_address&.order(:created_at)
    if client_service_address.present? && client_service_address.where(is_default: true).blank?
      client_service_address.first.update(is_default: true)
    end
  end
end
