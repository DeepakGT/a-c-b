class AttachmentPolicy < ApplicationPolicy
  def index?
    return true if permissions.include?('client_files_view') || update? || destroy?
  end

  def show?
    if record.permissions.present? && record.permissions.include?(user.role_name)
      return true if permissions.include?('client_files_view')
    end

    return true if permissions.include?('client_files_view') || update? || destroy?

    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('client_files_update')

    false
  end

  def destroy?
    return true if permissions.include?('client_files_delete')

    false
  end
end
