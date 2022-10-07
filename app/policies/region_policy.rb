class RegionPolicy < ApplicationPolicy
  def index?
    return true if permissions.include?('regions_view')

    false
  end

  def create?
    index?
  end

  def update?
    return true if permissions.include?('regions_update')

    false
  end
end
