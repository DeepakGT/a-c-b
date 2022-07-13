class SettingPolicy < ApplicationPolicy
  def show?
    return true if permissions.include?('settings')

    false
  end

  def update?
    return true if permissions.include?('settings')

    false
  end
end
