class ContactPolicy < ApplicationPolicy
  def index?
    show? || update? || destroy?
  end

  def show?
    return true if permissions.include?('client_contacts_view') || update? || destroy?
    
    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('client_contacts_update')

    false
  end

  def destroy?
    return true if permissions.include?('client_contacts_delete')

    false
  end
end
