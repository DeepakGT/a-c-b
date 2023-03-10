# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :rememberable, :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable
  include DeviseTokenAuth::Concerns::User

  # Attrs
  attr_accessor :role_id

  # Callbaks
  before_validation :assign_role, on: :create

  # Associations
  has_one :user_role, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy, inverse_of: :addressable
  has_many :phone_numbers, as: :phoneable, dependent: :destroy, inverse_of: :phoneable
  has_many :notifications, as: :recipient, dependent: :destroy
  has_one :rbt_supervision, dependent: :destroy
  
  has_one :role, through: :user_role

  accepts_nested_attributes_for :rbt_supervision, :address, :phone_numbers, allow_destroy: true

  # Enums
  enum status: {active: 0, inactive: 1}
  enum gender: { male: 'male', female: 'female', non_binary: 'non_binary' }
  enum job_type: {full_time: 'full_time', part_time: 'part_time'}
  enum default_schedule_view: {calendar: 'calendar', list: 'list'}

  # Validation
  validates_associated :role
  #validates_presence_of :role

  # Custom Validations
  # terminated_on field would also be validated with this
  PASSWORD_FORMAT = /\A(?=.{8,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[[:^alnum:]]) /x
  validates :password, presence: true, length: { in: Devise.password_length, wrong_length: "Password must be 8 to 128 characters long." },
                       format: { with: PASSWORD_FORMAT, message: "must contain one uppercase, one lowercase, one digit and one special character and must be minimum 8 characters long." },
                       confirmation: true, on: :create
  validate :validate_status

  # scopes
  scope :by_first_name, ->(fname){ where("first_name ILIKE '%#{fname}%'") }
  scope :by_last_name, ->(lname){ where("last_name ILIKE '%#{lname}%'") }
  scope :by_role, ->(title){ where("roles.name ILIKE '%#{title}%'")}
  scope :by_roles, ->(role_names){ joins(:role).where('role.name': role_names) }
  scope :by_creator, ->(creator){ find_by(id: creator) }

  # delegates
  delegate :name, to: :role, prefix: true, allow_nil: true

  # format response
  def as_json(options = {})
    response = super(options)
               .select { |key| key.in?(['id', 'email', 'uid', 'first_name', 'last_name', 'default_schedule_view']) }
               .merge({role: Role.find_by(name: self.role_name)})

    response.merge!({organization_id: self.organization&.id}) if self.role_name=='executive_director'
    if self.type=='Staff'
      response.merge!({default_location_id: self.staff_clinics&.home_clinic&.first&.clinic_id})
    else
      response.merge!({default_location_id: 1})
    end
    response
  end

  def organization
    return nil if self.role_name=='administrator' || self.role_name=='super_admin'
    return Organization.find_by(admin_id: self.id) if self.role_name=='executive_director'

    self.clinic.organization
  end

  def active_for_authentication?
    super and self.active?
  end

  def mark_notifications_as_read(ids)
    notifications.by_ids(ids).mark_as_read!
  end

  def allow_email_notifications?
    return true if self.deactivated_at.nil?

    false
  end

  private

  def assign_role
    # return if we are assigning role via association
    return if self.role_id.nil?

    self.role = Role.find(self.role_id)
  rescue StandardError => e
    errors.add(:role, e)
  end

  def validate_status
    errors.add(:status, 'For an inactive user, terminated date must be present.') if (self.type != 'Client' && self.inactive? && self.terminated_on.blank?)
  end
  # end of private
end
