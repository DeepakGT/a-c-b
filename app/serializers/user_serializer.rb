class UserSerializer < ApplicationSerializer
  attributes :id, :first_name, :last_name, :department, :immediate_supervisor,
  :phone, :extension, :hired_at, :role_name

  def department
    object.user_role.department
  end

  def immediate_supervisor
    return '' if object.supervisor.blank?
    "#{object.supervisor.first_name} #{object.supervisor.last_name}"
  end

  def phone
    object.phone_numbers.first&.number
  end

  def extension
    object.phone_ext
  end
end
