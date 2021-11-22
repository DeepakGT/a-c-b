class CompleteStaffSerializer < ApplicationSerializer
  attributes :id, :first_name, :last_name, :email, :web_address,
             :status, :pay_type, :hired_at, :service_provider, :timing_type,
             :hours_per_week, :terminated_at, :residency, :status_date, :driving_license,
             :driving_license_expires_at, :title, :gender, :department, :date_of_birth,
             :ssn, :badge_id, :badge_type, :supervisor
  has_one :address
  has_one :rbt_supervision
  has_many :phone_numbers
  has_many :services

  def title
    object.role_name
  end

  def department
    object.user_role.department
  end

end
