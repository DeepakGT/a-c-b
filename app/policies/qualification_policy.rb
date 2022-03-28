class QualificationPolicy < ApplicationPolicy
  def index?
    show? || update? || destroy?
  end

  def show?
    return true if permissions.include?('qualification_view') || update? || destroy?

    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('qualification_update')

    false
  end

  def destroy?
    return true if permissions.include?('qualification_delete')

    false
  end
end
