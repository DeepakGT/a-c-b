class RolePolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def update?
    false
  end
end
