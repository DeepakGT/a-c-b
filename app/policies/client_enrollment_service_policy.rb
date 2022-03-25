class ClientEnrollmentServicePolicy < ApplicationPolicy
  def index?
    show? || update? || destroy?
  end

  def show?
    return true if permissions.include?('client_authorization_view') || update? || destroy?

    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('client_authorization_update')

    false
  end

  def destroy?
    return true if permissions.include?('client_authorization_delete')

    false
  end
end
