class ClinicPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if permissions.include?('location_view') || update? || destroy? || user.role_name=='client_care_coordinator'

    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('location_update')

    false
  end

  def massive_region?
    update?
  end

  def destroy?
    return true if permissions.include?('location_delete')

    false
  end
end
