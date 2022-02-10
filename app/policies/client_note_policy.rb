class ClientNotePolicy < ApplicationPolicy
  def index?
    show? || update?
  end

  def show?
    return true if permissions.include?('client_notes_view') || update?

    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('client_notes_update')

    false
  end
end
