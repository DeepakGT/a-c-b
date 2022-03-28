class FundingSourcePolicy < ApplicationPolicy
  def index?
    show? || update? || destroy?
  end

  def show?
    return true if permissions.include?('funding_source_view') || update? || destroy?

    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('funding_source_update')

    false
  end

  def destroy?
    return true if permissions.include?('funding_source_delete')

    false
  end
end
