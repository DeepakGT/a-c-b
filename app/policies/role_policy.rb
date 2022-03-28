class RolePolicy < ApplicationPolicy
  def index?
    show? || update?
  end

  def show?
    return true if permissions.include?('roles_view') || update?

    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('roles_update')

    false
  end

  def destroy?
    return true if permissions.include?('roles_delete')

    false
  end
end
