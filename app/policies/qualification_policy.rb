class QualificationPolicy < ApplicationPolicy
  def index?
    show? || update?
  end

  def show?
    return true if permissions.include?('qualification_view') || update?

    false
  end

  def create?
    update?
  end

  def update?
    return true if permissions.include?('qualification_update')

    false
  end
end
