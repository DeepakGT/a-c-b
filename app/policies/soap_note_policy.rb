class SoapNotePolicy < ApplicationPolicy
  def index?
    show? || update? || destroy?
  end

  def show?
    return true if permissions.include?('soap_notes_view') || update? || destroy?
    
    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('soap_notes_update')

    false
  end

  def destroy?
    return true if permissions.include?('soap_notes_delete')

    false
  end
end
