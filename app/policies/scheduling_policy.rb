class SchedulingPolicy < ApplicationPolicy
  def index?
    show? || update? 
  end

  def show?
    return true if permissions.include?('scheduling_view') || update? 
    
    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('scheduling_update')

    false
  end
end
