class SchedulingChangeRequestPolicy < ApplicationPolicy
  def create?
    return true if user.role_name=='rbt'

    false
  end

  def update?
    return true if user.role_name=='bcba' || user.role_name=='aba_admin' || user.role_name=='ed'

    false
  end
end
