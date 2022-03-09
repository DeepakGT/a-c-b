class ClientEnrollment < ApplicationRecord
  before_save :set_status

  belongs_to :client
  belongs_to :funding_source, optional: true
  has_many :client_enrollment_services

  enum relationship: { parent_or_guardian: 0, spouse_or_partner: 1, self: 2 }, _prefix: true
  enum source_of_payment: { self_pay: 0, insurance: 1, single_case_agreement: 2 }

  scope :active, ->{ where('terminated_on > ?',Time.now.to_date).or(where('terminated_on IS NULL')) }
  scope :except_ids, ->(ids) { where.not(id: ids) }

  private

  def set_status
    if self.client.status=='inactive' && (self.terminated_on.blank? || self.terminated_on > Time.now.to_date)
      self.client.status = Client.statuses['active'] 
    end
  end
  # end of private
  
end
