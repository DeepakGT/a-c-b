class UserClinicsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_staff
  before_action :set_user_clinic, only: %i[update destroy]

  def index 
    @user_clinics = @staff.user_clinics.order(is_home_clinic: :desc)
  end

  def update
    @user_clinic.update(update_params)
  end

  def destroy
    @user_clinic.destroy
  end

  private

  def set_staff
    @staff = Staff.find(params[:staff_id])
  end

  def set_user_clinic
    @user_clinic = @staff.user_clinics.find(params[:id])
  end

  def update_params
    params.permit(:clinic_id, :is_home_clinic)
  end
  # end of private
end
