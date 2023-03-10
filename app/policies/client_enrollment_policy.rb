class ClientEnrollmentPolicy < ApplicationPolicy
  def index?
    show? || update? || destroy?
  end

  def show?
    return true if permissions.include?('client_source_of_payment_view') || update? || destroy?

    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('client_source_of_payment_update')

    false
  end

  def destroy?
    return true if permissions.include?('client_source_of_payment_delete')

    false
  end
end
