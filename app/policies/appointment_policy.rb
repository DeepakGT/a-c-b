class AppointmentPolicy < ApplicationPolicy
  def rbt_appointments?
    return true if user.role_name=='rbt'

    false
  end

  def bcba_appointments?
    return true if user.role_name=='bcba' || user.role_name=='Lead RBT'

    false
  end

  def executive_director_appointments?
    return true if ['super_admin', 'executive_director', 'administrator', 'client_care_coordinator'].include?(user.role_name)

    false
  end
end
