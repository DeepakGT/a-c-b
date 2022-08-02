class UserPolicy < ApplicationPolicy
  def super_admins_list?
    return true if user.role_name=='system_administrator'
    
    false
  end

  def create_super_admin?
    super_admins_list?
  end
end
