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
  before_validation :assign_role, on: [:create]

  # Associations
  has_one :user_role, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy
  has_one :rbt_supervision, dependent: :destroy
  has_many :phone_numbers, as: :phoneable, dependent: :destroy
  has_many :user_services, dependent: :destroy
  
  has_one :role, through: :user_role
  has_many :services, through: :user_services

  belongs_to :clinic
  belongs_to :supervisor, class_name: :User, optional: true

  accepts_nested_attributes_for :address, :allow_destroy => true
  accepts_nested_attributes_for :phone_numbers, :allow_destroy => true
  accepts_nested_attributes_for :services, :allow_destroy => true
  accepts_nested_attributes_for :rbt_supervision, :allow_destroy => true

  # Enums
  enum status: {active: 0, inactive: 1}
  enum pay_type: {hourly: 0, independent_contract: 1, salaried: 2, other: 3}
  enum timing_type: {full_time: 0, part_time: 1}
  enum term_type: {involuntary: 0, voluntary: 1}
  enum residency: {green_card: 0, us_citizen: 1, work_visa: 2}
  enum badge_type: { custom: 0,
                     agency_aka_database_id: 1,
                     database_id: 2,
                     first_name_last_name_id: 3 }

  # Validation
  validates_associated :role
  validates_presence_of :role
  validates :hours_per_week, length: {maximum: 120}, allow_blank: true

  # Custom Validations
  # terminated_at field would also be validated with this
  validate :validate_status

  # delegates
  delegate :name, to: :role, prefix: true

  # format response
  def as_json(options = {})
    super(options)
      .select { |key| key.in?(['email', 'uid', 'first_name', 'last_name']) }
      .merge({role: Role.names[self.role_name]})
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

  # end of private

end
