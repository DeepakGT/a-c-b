class AddressPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    return true if permissions.include?('client_service_address_view')

    false
  end

  def create?
    return true if permissions.include?('client_service_address_update')

    false
  end

  def update?
    return true if user.role_name=='super_admin' || (Scheduling.where(service_address_id: @record.id).blank? && permissions.include?(client_service_address_update))

    false
  end

  def destroy?
    return true if Scheduling.where(service_address_id: @record.id).blank? && permissions.include?(client_service_address_delete)

    false
  end
end
