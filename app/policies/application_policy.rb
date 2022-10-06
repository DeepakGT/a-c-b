# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :permissions, :record
  
  def initialize(user, record, permissions = user.role.permissions)
    @user = user
    @record = record
    @permissions = permissions
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

    attr_reader :user, :scope
  end
end
