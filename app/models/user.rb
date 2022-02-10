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
  has_one :rbt_supervision, dependent: :destroy
  has_many :user_services, dependent: :destroy
  
  has_one :role, through: :user_role
  has_many :services, through: :user_services

  accepts_nested_attributes_for :services, :update_only => true
  accepts_nested_attributes_for :rbt_supervision, :update_only => true

  # Enums
  enum status: {active: 0, inactive: 1}
  enum gender: {male: 0, female: 1}

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
  scope :by_first_name, ->(fname){ where('lower(first_name) LIKE ?',"%#{fname.downcase}%") }
  scope :by_last_name, ->(lname){ where('lower(last_name) LIKE ?', "%#{lname&.downcase}%") }
  scope :by_role, ->(role_name){ where('role.name.downcase': role_name&.downcase)}

  # delegates
  delegate :name, to: :role, prefix: true, allow_nil: true

  # format response
  def as_json(options = {})
    response = super(options)
               .select { |key| key.in?(['email', 'uid', 'first_name', 'last_name']) }
               .merge({role: Role.find_by(name: self.role_name)})

    response.merge!({organization_id: self.organization&.id}) if self.role_name=='aba_admin'
    response
  end

  def organization
    return nil if self.role_name=='administrator' || self.role_name=='super_admin'
    return Organization.find_by(admin_id: self.id) if self.role_name=='aba_admin'

    self.clinic.organization
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
    errors.add(:status, 'For an active user, terminated date must be blank.') if self.active? && self.terminated_on.present?
    errors.add(:status, 'For an inactive user, terminated date must be present.') if self.inactive? && self.terminated_on.blank?
  end

  # end of private

end
