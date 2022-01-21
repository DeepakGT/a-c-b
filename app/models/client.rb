class Client < User
  has_many :contacts, dependent: :destroy
  has_many :addresses, as: :addressable, dependent: :destroy
  has_one :phone_number, as: :phoneable, dependent: :destroy
  has_many :client_enrollments, dependent: :destroy
  has_many :funding_sources, through: :client_enrollments

  accepts_nested_attributes_for :addresses, update_only: true
  accepts_nested_attributes_for :phone_number, update_only: true

  enum payer_status: {in_network: 0, medicaid: 1, out_of_network: 2, scholarship: 3, self_pay: 4, single_case_agreement: 5}
  enum preferred_language: {english: 0, spanish: 1}
  enum dq_reason: { lost_contact: 0, not_clinically_appropriate: 1, insurance_denial: 2, no_longer_interested: 3, 
                    competitor: 4, not_ready_to_move_forward: 5, other: 6}

  validate :validate_presence_of_dq_reason

  private

  def validate_presence_of_dq_reason
    errors.add(:disqualified, 'For a disqualified client, reason must be specified.') if self.disqualified == true && self.dq_reason.blank?
    errors.add(:qualified, 'For a qualified client, disqualification reason must be blank.') if self.disqualified == false && self.dq_reason.present?
  end
end
