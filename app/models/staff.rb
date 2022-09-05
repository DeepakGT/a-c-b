class Staff < User
  has_many :staff_qualifications, dependent: :destroy, foreign_key: :staff_id
  has_many :qualifications, through: :staff_qualifications
  has_many :staff_clinics, dependent: :destroy
  has_many :clinics, through: :staff_clinics
  has_many :client_enrollment_service_providers, dependent: :destroy
  has_many :client_enrollment_services, through: :client_enrollment_service_providers
  has_many :schedulings, dependent: :destroy

  belongs_to :supervisor, class_name: :User, optional: true
  
  # validations for role
  validate :validate_role

  before_validation :set_status

  # scopes
  scope :by_organization, ->(org_name){ where("organizations.name ILIKE '%#{org_name}%'")}
  scope :by_supervisor_full_name, ->(fname,lname){ where(supervisor_id: User.by_first_name(fname).by_last_name(lname).ids) }
  scope :by_supervisor_first_name, ->(fname){ where(supervisor_id: User.by_first_name(fname).ids) }
  scope :by_supervisor_last_name, ->(fname){ where(supervisor_id: User.by_last_name(fname).ids) }
  scope :by_clinic, ->(clinic_id){ joins(:staff_clinics).where('staff_clinics.clinic_id = ?', clinic_id) }
  scope :by_home_clinic, ->(clinic_id){ joins(:staff_clinics).where('staff_clinics.clinic_id = ? AND staff_clinics.is_home_clinic = ?', clinic_id, true) }
  scope :by_service_qualifications, ->(service_qualification_ids){ joins(:staff_qualifications).where('staff_qualifications.credential_id': service_qualification_ids) }
  scope :active, ->{ where(status: 'active') }
  scope :inactive, ->{ where(status: 'inactive') }

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

  def billable_hours_for_current_week
    start_date = Time.current.at_beginning_of_week.to_date
    end_date = Time.current.at_end_of_week.to_date
    appointments = Scheduling.within_dates(start_date, end_date).where(status: ['auth_pending', 'scheduled', 'rendered'])
    appointments.present? ? (appointments.pluck(:minutes)&.sum).to_f/60.0 : 0
  end

  private

  def validate_role
    errors.add(:role, 'cannot be super_admin for staff.') if self.role_name=='super_admin'
  end

  def set_status
    if self.terminated_on.present? && self.terminated_on <= Time.current.to_date
      self.status = Staff.statuses['inactive'] 
    elsif self.terminated_on.blank? || self.terminated_on > Time.current.to_date
      self.status = Staff.statuses['active'] 
    end
  end
  # end of privates
end
