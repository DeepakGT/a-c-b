class ServicePolicy < ApplicationPolicy
  def index?
    show? || update?
  end

  def show?
    return true if permissions.include?('service_view') || update?

    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('service_update')

    false
  end
end
