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
    @staff_clinic = @staff.staff_clinics.create(staff_clinic_params)
  end

  def update
    @staff_clinic.update(staff_clinic_params)
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
    params.permit(:clinic_id, :is_home_clinic)
  end
  # end of private
end
