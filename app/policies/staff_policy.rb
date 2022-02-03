class StaffPolicy < ApplicationPolicy
  def index?
    show? || update? || destroy?
  end

  def show?
    return true if permissions.include?('staff_view') || update? || destroy?
    
    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('staff_update')

    false
  end

  def destroy?
    return true if permissions.include?('staff_delete')

    false
  end
end
