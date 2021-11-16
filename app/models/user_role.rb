class UserRole < ApplicationRecord

  belongs_to :user
  belongs_to :role

  enum department: {administration: 0, clinical_staff: 1}

end
