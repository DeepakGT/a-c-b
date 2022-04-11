class SchedulingChangeRequestPolicy < ApplicationPolicy
  def create?
    return true if user.role_name=='rbt'

    false
  end

  def update?
    return true if user.role_name=='bcba' || user.role_name=='executive_director' || user.role_name=='ed' || user.role_name=='client_care_coordinator'

    false
  end
end
