class Client < User
  has_one :phone_number, as: :phoneable, dependent: :destroy
  has_one :note, class_name: :ClientNote

  has_many :contacts, dependent: :destroy
  has_many :addresses, as: :addressable, dependent: :destroy
  has_many :client_enrollments, dependent: :destroy
  has_many :funding_sources, through: :client_enrollments
  
  belongs_to :clinic

  accepts_nested_attributes_for :addresses, update_only: true
  accepts_nested_attributes_for :phone_number, update_only: true
  accepts_nested_attributes_for :note

  enum payer_status: {self_pay: 0, single_case_agreement: 1, insurance: 2}
  enum preferred_language: {english: 0, spanish: 1}
  enum dq_reason: { lost_contact: 0, not_clinically_appropriate: 1, insurance_denial: 2, no_longer_interested: 3, 
                    competitor: 4, not_ready_to_move_forward: 5, other: 6}

  validates :dq_reason, presence: true, if: ->{ self.disqualified? }
  validates :dq_reason, absence: true, if: ->{ !self.disqualified? }

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
end
