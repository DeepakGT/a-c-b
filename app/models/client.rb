CLINIC_ROLES = ['bcba', 'Clinical Director'].freeze

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
  enum gender: {male: 'male', female: 'female', no_binary: 'no_binary'}
  enum preferred_language: {english: 0, spanish: 1}
  enum dq_reason: { lost_contact: 0, not_clinically_appropriate: 1, insurance_denial: 2, no_longer_interested: 3, 
                    competitor: 4, not_ready_to_move_forward: 5, other: 6}

  validates :dq_reason, presence: true, if: ->{ self.disqualified? }
  validates :dq_reason, absence: true, if: ->{ !self.disqualified? }

  scope :by_clinic, ->(clinic_id){ where(clinic_id: clinic_id) }
  scope :by_bcbas, ->(bcba_ids) { where(primary_bcba_id: bcba_ids).or(where(secondary_bcba_id: bcba_ids)) }
  scope :by_staff_id_in_scheduling, ->(staff_id){ joins(client_enrollments: {client_enrollment_services: :schedulings}).where('schedulings.staff_id = ?', staff_id) }
  scope :with_no_authorizations, ->{ left_outer_joins(client_enrollments: :client_enrollment_services).select('clients.*').group('clients.id').having('count(client_enrollment_services.*) = ?',0) }
  scope :active, ->{ where(status: 'active') }
  scope :inactive, ->{ where(status: 'inactive') }
  scope :by_first_name, ->(fname){ where("first_name ILIKE '%#{fname}%'") }
  scope :by_last_name, ->(lname){ where("last_name ILIKE '%#{lname}%'") }
  scope :by_bcba_full_name, ->(fname,lname){ where(primary_bcba_id: User.by_roles(['bcba', 'Clinical Director']).by_first_name(fname).by_last_name(lname)&.ids).or(where(secondary_bcba_id: User.by_roles(['bcba', 'Clinical Director']).by_first_name(fname).by_last_name(lname)&.ids)) }
  scope :by_bcba_first_name, ->(fname){ where(primary_bcba_id: User.by_roles(['bcba', 'Clinical Director']).by_first_name(fname)&.ids).or(where(secondary_bcba_id: User.by_roles(['bcba', 'Clinical Director']).by_first_name(fname)&.ids)) }
  scope :by_bcba_last_name, ->(fname){ where(primary_bcba_id: User.by_roles(['bcba', 'Clinical Director']).by_last_name(lname)&.ids).or(where(secondary_bcba_id: User.by_roles(['bcba', 'Clinical Director']).by_last_name(lname)&.ids)) }
  scope :by_gender, ->(gender_value){ where(gender: Client.genders[gender_value] || -1) }
  scope :by_payor_status, ->(payor_status_value){ where("payor_status ILIKE '%#{payor_status_value}%'") }
  scope :by_payor, ->(payor_name){ left_outer_joins(client_enrollments: :funding_source).where("client_enrollments.is_primary = ?", true).where("client_enrollments.terminated_on >= ? OR terminated_on IS NULL", Time.current.strftime('%Y-%m-%d')).where("funding_sources.name ILIKE '%#{payor_name}%'") }
  scope :with_appointment_after_last_30_days, ->{where('schedulings.date >= ?', (Date.current - 30.days))}

  def save_with_exception_handler
    self.save
  rescue StandardError => e
    errors.add(:address_type, "already present.") if e.is_a? ActiveRecord::RecordNotUnique
  end

  def update_with_exception_handler(client_params)
    self.update(client_params)
  rescue StandardError => e
    errors.add(:address_type, "already present.") if e.is_a? ActiveRecord::RecordNotUnique
  end

  def days_since_creation
    (Time.current.to_date - (self.created_at).to_date).to_i
  end

  def early_authorizations
    ClientEnrollmentService.by_client(self.id).joins(:service).including_early_codes.joins(:client_enrollment).with_funding_sources
  end

  def non_early_authorizations_except_97151
    ClientEnrollmentService.by_client(self.id).joins(:service).excluding_early_codes.excluding_97151_service.joins(:client_enrollment).with_funding_sources
  end

  def funding_source_ids
    self.early_authorizations.map{|authorization| authorization.client_enrollment.funding_source_id}.uniq.compact
  end

  private

  def set_default_service_address
    client_service_address = self.addresses.by_service_address&.order(:created_at)
    client_service_address.first.update(is_default: true) if client_service_address.present? && client_service_address.where(is_default: true).blank?
  end

  def self.transform_gender
    genders.map do |type, _|
      {'value' => type, 'title'=> I18n.t("activerecord.attributes.client.gender.#{type}").capitalize }
    end
  end

end
