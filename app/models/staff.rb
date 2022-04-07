class Staff < User
  has_many :staff_qualifications, dependent: :destroy, foreign_key: :staff_id
  has_many :qualifications, through: :staff_qualifications
  has_one :address, as: :addressable, dependent: :destroy, inverse_of: :addressable
  has_many :phone_numbers, as: :phoneable, dependent: :destroy, inverse_of: :phoneable
  has_many :staff_clinics, dependent: :destroy
  has_many :clinics, through: :staff_clinics
  has_many :client_enrollment_service_providers, dependent: :destroy
  has_many :client_enrollment_services, through: :client_enrollment_service_providers
  has_many :schedulings, dependent: :destroy

  belongs_to :supervisor, class_name: :User, optional: true

  accepts_nested_attributes_for :address, :update_only => true
  accepts_nested_attributes_for :phone_numbers, :update_only => true
  
  # validations for role
  validate :validate_role

  before_validation :set_status

  # scopes
  scope :by_organization, ->(org_name){ where('lower(organizations.name) = ?', org_name&.downcase)}
  scope :by_supervisor_name, ->(fname,lname){ where(supervisor_id: User.by_first_name(fname&.downcase).by_last_name(lname&.downcase)) }
  scope :by_clinic, ->(clinic_id){ joins(:staff_clinics).where('staff_clinics.clinic_id = ?', clinic_id) }
  scope :by_roles, ->(role_names){ joins(:role).where('role.name': role_names) }
  scope :by_service_qualifications, ->(service_qualification_ids){ joins(:staff_qualifications).where('staff_qualifications.credential_id': service_qualification_ids) }

  def self.by_location(query) 
    staff = self
    query.split.each do |q|
      staff = staff.where('lower(addresses.line1) LIKE :loc OR
        lower(addresses.line2) LIKE :loc OR
        lower(addresses.line3) LIKE :loc OR
        lower(addresses.zipcode) LIKE :loc OR
        lower(addresses.city) LIKE :loc OR
        lower(addresses.state) LIKE :loc OR
        lower(addresses.country) LIKE :loc', loc: "%#{q&.downcase}%")
    end
    staff
  end

  private

  def validate_role
    errors.add(:role, 'cannot be super_admin for staff.') if self.role_name=='super_admin'
  end

  def set_status
    if self.terminated_on.present? && self.terminated_on <= Time.now.to_date
      self.status = Staff.statuses['inactive'] 
    elsif self.terminated_on.blank? || self.terminated_on > Time.now.to_date
      self.status = Staff.statuses['active'] 
    end
  end
  # end of privates
end
