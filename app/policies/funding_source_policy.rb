class FundingSourcePolicy < ApplicationPolicy
  def index?
    show? || update?
  end

  def show?
    return true if permissions.include?('funding_source_view') || update?

    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('funding_source_update')

    false
  end
end
