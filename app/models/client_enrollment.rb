class ClientEnrollment < ApplicationRecord
  before_save :set_status
  before_validation :set_funding_source, on: :update

  belongs_to :client
  belongs_to :funding_source, optional: true
  has_many :client_enrollment_services, dependent: :destroy

  enum relationship: { parent_or_guardian: 0, spouse_or_partner: 1, self: 2 }, _prefix: true
  enum source_of_payment: { self_pay: 0, insurance: 1, single_case_agreement: 2 }

  validates_presence_of :terminated_on
  validate :validate_source_of_payment
  validate :validate_funding_source

  scope :active, ->{ where('terminated_on > ?',Time.now.to_date).or(where('terminated_on IS NULL')) }
  scope :except_ids, ->(ids) { where.not(id: ids) }
  scope :by_source_of_payment, ->(sources){ where(source_of_payment: sources)}

  private

  def set_status
    if self.client.status=='inactive' && (self.terminated_on.blank? || self.terminated_on > Time.now.to_date)
      self.client.status = Client.statuses['active'] 
    end
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
