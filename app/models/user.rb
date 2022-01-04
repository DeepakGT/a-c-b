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
  has_one :address, as: :addressable, dependent: :destroy
  has_one :rbt_supervision, dependent: :destroy

  has_many :phone_numbers, as: :phoneable, dependent: :destroy
  has_many :user_services, dependent: :destroy
  has_many :staff_credentials, dependent: :destroy, foreign_key: :staff_id
  
  has_one :role, through: :user_role
  has_many :services, through: :user_services
  has_many :credentials, through: :staff_credentials

  belongs_to :clinic, optional: true
  belongs_to :supervisor, class_name: :User, optional: true

  accepts_nested_attributes_for :address, :update_only => true
  accepts_nested_attributes_for :phone_numbers, :update_only => true
  accepts_nested_attributes_for :services, :update_only => true
  accepts_nested_attributes_for :rbt_supervision, :update_only => true

  # Enums
  enum status: {active: 0, inactive: 1}
  enum gender: {male: 0, female: 1}

  # Validation
  validates_associated :role
  #validates_presence_of :role

  # Custom Validations
  # terminated_at field would also be validated with this
  validate :validate_status
  validate :validate_presence_of_clinic

  # scopes
  scope :by_staff_roles, ->{ where('role.name': ['bcba','rbt','billing']) }

  # delegates
  delegate :name, to: :role, prefix: true, allow_nil: true

  # define methods dynamically, to check the user's role
  # like user.aba_admin?
  Role.names.each_key do |key|
    define_method "#{key}?" do
      self.role_name == key
    end
  end

  # format response
  def as_json(options = {})
    response = super(options)
               .select { |key| key.in?(['email', 'uid', 'first_name', 'last_name']) }
               .merge({role: Role.names[self.role_name]})

    response.merge!({organization_id: self.organization&.id}) if self.aba_admin?
    response.merge!({address: self.address})
    response.merge!(phone_numbers: self.phone_numbers)
    response
  end

  def organization
    return nil if self.administrator?
    return Organization.find_by(admin_id: self.id) if self.aba_admin?

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
    errors.add(:status, 'For an active user, terminated date must be blank.') if self.active? && self.terminated_at.present?
    errors.add(:status, 'For an inactive user, terminated date must be present.') if self.inactive? && self.terminated_at.blank?
  end

  def validate_presence_of_clinic
    return if self.aba_admin? || self.administrator?

    errors.add(:clinic, 'must be associate with this user.') if self.clinic.blank?
  end

  # end of private

end
