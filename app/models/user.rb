# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :rememberable, :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable
  include DeviseTokenAuth::Concerns::User

  # Attribute accessors
  attr_accessor :role_name

  # Callbaks
  before_validation :assign_role, on: [:create]

  # Associations
  has_one :user_role, dependent: :destroy
  has_one :address, as: :addressable
  has_many :phone_numbers, as: :phoneable
  has_many :user_services
  
  has_one :role, through: :user_role
  has_many :services, through: :user_services

  belongs_to :supervisor, class_name: :User

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

  # format response
  def as_json(options = {})
    super(options)
      .select { |key| key.in?(['email', 'uid', 'first_name', 'last_name']) }
      .merge({role: humanize_role_name})
  end

  private

  # access actual role name, which is in database
  def humanize_role_name
    Role.names[self.role&.name]
  end

  def assign_role
    role = self.role || Role.where(name: self.role_name).first || Role.new(name: self.role_name)
    self.role = role
  rescue StandardError => e
    errors.add(:role_name, e)
  end

  # end of private

end
