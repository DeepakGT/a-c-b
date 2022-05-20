class StaffClinicsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_staff
  before_action :set_staff_clinic, only: %i[show update destroy]

  def index 
    @staff_clinics = @staff.staff_clinics.order(is_home_clinic: :desc)
  end

  def show; end
  
  def create
    @staff_clinic = @staff.staff_clinics.new(staff_clinic_params)
    remove_home_clinic if params[:is_home_clinic].to_bool.true?
    @staff_clinic.save
  end

  def update
    StaffClinic.transaction do
      remove_services # if params[:staff_clinic_services_attributes].present?
      remove_home_clinic if params[:is_home_clinic].to_bool.true?
      @staff_clinic.update(staff_clinic_params)
    end
  end

  def destroy
    @staff_clinic.destroy
  end

  private

  def authorize_user
    authorize StaffClinic if current_user.role_name != 'super_admin'
  end

  def set_staff
    @staff = Staff.find(params[:staff_id])
  end

  def set_staff_clinic
    @staff_clinic = @staff.staff_clinics.find(params[:id])
  end

  def staff_clinic_params
    params.permit(:clinic_id, :is_home_clinic, staff_clinic_services_attributes: %i[service_id])
  end

  def remove_services
    @staff_clinic.staff_clinic_services.destroy_all
  end

  def remove_home_clinic
    home_clinics = @staff.staff_clinics.where(is_home_clinic: true)
    if home_clinics.present?
      home_clinics.update_all(is_home_clinic: false)
    end
  end
  # end of private
end
