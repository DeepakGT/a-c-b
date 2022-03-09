class StaffQualificationPolicy < ApplicationPolicy
  def index?
    show? || update? || destroy?
  end

  def show?
    return true if permissions.include?('staff_qualification_view') || update? || destroy?

    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('staff_qualification_update')

    false
  end

  def destroy?
    return true if permissions.include?('staff_qualification_delete')

    false
  end
end
