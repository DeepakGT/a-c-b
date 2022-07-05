class ClientServiceAddressPolicy < ApplicationPolicy
  def update?
    return true if user.role_name=='super_admin' || Scheduling.where(service_address_id: @record.id).blank?

    false
  end

  def destroy?
    return true if Scheduling.where(service_address_id: @record.id).blank?

    false
  end
end
