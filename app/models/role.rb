class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  validates :name, uniqueness: true
  validates :name, presence: true

  enum name: { aba_admin: 'aba admin',
               administrator: 'administrator',
               bcba: 'bcba',
               rbt: 'rbt',
               billing: 'billing',
               client: 'client' }
end
