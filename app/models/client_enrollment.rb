class ClientEnrollment < ApplicationRecord
  before_save :set_status
  before_validation :set_funding_source, on: :update

  belongs_to :client
  belongs_to :funding_source, optional: true
  has_many :client_enrollment_services, dependent: :destroy

  enum relationship: { self: 0, parent_or_guardian: 1, spouse_or_partner: 2, lci_or_foster_home: 3, 
                       external_contact: 4, internal_contact: 5 }, _prefix: true
  enum source_of_payment: { self_pay: 0, insurance: 1, single_case_agreement: 2 }
  enum payor_status: { sca: 'sca', oon: 'oon', iin: 'iin', p2p: 'p2p', self_pay: 'self_pay' }, _prefix: true

  validate :validate_source_of_payment
  validate :validate_funding_source
  validates_presence_of :subscriber_dob

  scope :active, ->{ where('terminated_on >= ?',Time.current.to_date).or(where('terminated_on IS NULL')) }
  scope :except_ids, ->(ids) { where.not(id: ids) }
  scope :by_source_of_payment, ->(sources){ where(source_of_payment: sources)}
  scope :billable_funding_sources, ->{where.not('funding_sources.network_status': 'non_billable')}
  scope :non_billable_funding_sources, ->{where('funding_sources.network_status': 'non_billable')}

  def self.translate_payor_statuses
    payor_statuses.map do |k, v|
      { 'value' => k, 'title' => I18n.t("activerecord.attributes.client_enrollment.payor_statuses.#{k}") }
    end
  end

  private

  def set_status
    self.client.status = Client.statuses['active'] if (self.terminated_on.blank? || self.terminated_on > Time.current.to_date) && self.client.inactive?
  end

  def validate_source_of_payment
    return if client.client_enrollments.count == 0

    if client.client_enrollments.by_source_of_payment('self_pay').active.except_ids(self.id).present?
      errors.add(:client, 'cannot have more source of payments as self is already present.')
    elsif client.client_enrollments.by_source_of_payment('insurance').active.except_ids(self.id).present? && self.source_of_payment=='self_pay'
      errors.add(:client, 'cannot have self source of payment since insurance are already present.')
    end
  end

  def validate_funding_source
    errors.add(:funding_source, 'must be present.') if self.source_of_payment!='self_pay' && self.funding_source_id.blank?
    errors.add(:funding_source, 'must be absent.') if self.source_of_payment=='self_pay' && self.funding_source_id.present?
  end

  def set_funding_source
    self.funding_source_id = nil if self.source_of_payment=='self_pay'
  end
  # end of private

end
