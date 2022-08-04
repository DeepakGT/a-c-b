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

  def create_early_auths?
    authorizations = ClientEnrollmentService.by_client(record.id).joins(:service).where.not('services.display_code': '97151')
    return true if permissions.include?('early_auth_update') && ((Time.current.to_date - (record.created_at).to_date).to_s[0..-3].to_i<=90) && authorizations.blank?

    false
  end

  def replace_early_auth?
    return true if permissions.include?('early_auth_update')

    false
  end
end
