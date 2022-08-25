class AttachmentPolicy < ApplicationPolicy
  def index?
    return true if permissions.include?('client_files_view') || update? || destroy?
  end

  def show?
    if record.role_permissions.present? && record.role_permissions.include?(user.role_name)
      return true if permissions.include?('client_files_view')
    elsif record.role_permissions.present? && !record.role_permissions.include?(user.role_name)
      return false
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
