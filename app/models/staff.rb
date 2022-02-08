class Staff < User
  has_many :staff_credentials, dependent: :destroy, foreign_key: :staff_id
  has_many :credentials, through: :staff_credentials
  has_one :address, as: :addressable, dependent: :destroy
  has_many :phone_numbers, as: :phoneable, dependent: :destroy

  belongs_to :supervisor, class_name: :User, optional: true

  accepts_nested_attributes_for :address, :update_only => true
  accepts_nested_attributes_for :phone_numbers, :update_only => true
  # validations for role
  validate :validate_role

  # scopes
  scope :by_organization, ->(org_name){ where('organization.name.downcase': org_name&.downcase)}
  scope :by_supervisor_name, ->(fname,lname){ where(supervisor_id: User.by_first_name(fname&.downcase).by_last_name(lname&.downcase)) }
  scope :by_location, ->(location) do 
    staff = self
    location.each do |loc|
      break if staff.none?
      
      staff = staff.where('lower(addresses.line1) LIKE :loc OR
        lower(addresses.line2) LIKE :loc OR
        lower(addresses.line3) LIKE :loc OR
        lower(addresses.zipcode) LIKE :loc OR
        lower(addresses.city) LIKE :loc OR
        lower(addresses.state) LIKE :loc OR
        lower(addresses.country) LIKE :loc', loc: loc&.downcase)
    end
    staff
  end

  private

  def validate_role
    errors.add(:role, 'For staff, role must be bcba, rbt or billing.') if !self.bcba? && !self.billing? && !self.rbt?
  end
end