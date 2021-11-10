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
  has_one :role, through: :user_role

  # Validation
  validates_associated :role
  validates_presence_of :role

  # format response
  def as_json(options={})
    super(options)
    .select{|key| key.in?(['email', 'uid', 'first_name', 'last_name'])}
    .merge({role: humanize_role_name})
  end

  private

    # access actual role name, which is in database
    def humanize_role_name
      Role.names[self.role&.name]
    end

    def assign_role
      role = Role.where(name: self.role_name).first || Role.new(name: self.role_name)
      self.role = role
    rescue StandardError => e
      errors.add(:role_name, e)
    end

  # end of private

end
