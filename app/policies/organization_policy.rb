class OrganizationPolicy < ApplicationPolicy
  def index?
    show? || update? || destroy?
  end

  def show?
    return true if permissions.include?('organization_view') || update? || destroy?

    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('organization_update') || user.role_name=='executive_director'

    false
  end

  def destroy?
    return true if permissions.include?('organization_delete')

    false
  end
end
