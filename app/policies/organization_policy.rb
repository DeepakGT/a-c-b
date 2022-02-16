class OrganizationPolicy < ApplicationPolicy
  def index?
    show? || update?
  end

  def show?
    return true if permissions.include?('organization_view') || update?

    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('organization_update')

    false
  end
end
