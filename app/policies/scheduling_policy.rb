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

  def range_recurrences?
    return true if permissions.include?('schedule_update')

    false
  end

  def pattern_recurrences?
    return true if permissions.include?('schedule_update')

    false
  end

  def update?
    return true if permissions.include?('schedule_update') && (user.role_name=='bcba' || user.role_name=='administrator' || user.role_name=='executive_director' || user.role_name=='super_admin' || user.role_name=='client_care_coordinator' || user.role_name=='Clinical Director')

    false
  end

  def destroy?
    return true if permissions.include?('schedule_delete')

    false
  end

  def create_without_staff?
    return true if permissions.include?('schedule_update_for_unassigned_client')

    false
  end

  def create_without_client?
    return true if permissions.include?('schedule_update_for_unassigned_staff')

    false
  end

  def update_without_client?
    create_without_client?
  end
end
