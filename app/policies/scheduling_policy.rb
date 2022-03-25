class SchedulingPolicy < ApplicationPolicy
  def index?
    show? || update? || destroy?
  end

  def show?
    return true if permissions.include?('schedule_view') || update? || destroy?
    
    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('schedule_update')

    false
  end

  def destroy?
    return true if permissions.include?('schedule_delete')

    false
  end
end
