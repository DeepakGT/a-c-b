class SchedulingPolicy < ApplicationPolicy
  def index?
    show? || update? || destroy?
  end

  def show?
    return true if permissions.include?('schedule_view') || update? || destroy?
    
    false
  end

  def create?
    return true if permissions.include?('schedule_update')

    false
  end

  def update?
    return true if permissions.include?('schedule_update') && (user.role_name=='bcba' || user.role_name=='administrator' || user.role_name=='executive_director' || user.role_name=='super_admin' || user.role_name=='client_care_coordinator')

    false
  end

  def destroy?
    return true if permissions.include?('schedule_delete')

    false
  end
end
