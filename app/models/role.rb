class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
end
