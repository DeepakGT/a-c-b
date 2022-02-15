class StaffClinicsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_staff
  before_action :set_staff_clinic, only: %i[update destroy]

  def index 
    @staff_clinics = @staff.staff_clinics.order(is_home_clinic: :desc)
  end

  def create
    clinics = (params[:clinics].class==String) ? JSON.parse(params[:clinics]) : params[:clinics]
    @staff_clinics = clinics.map do |clinic|
      @staff.staff_clinics.create(clinic_id: clinic["clinic_id"], is_home_clinic: clinic["is_home_clinic"])
    end
  end

  def update
    @staff_clinic.update(update_params)
  end

  def destroy
    @staff_clinic.destroy
  end

  private

  def set_staff
    @staff = Staff.find(params[:staff_id])
  end

  def set_staff_clinic
    @staff_clinic = @staff.staff_clinics.find(params[:id])
  end

  def update_params
    params.permit(:clinic_id, :is_home_clinic)
  end

  def create_params
    params.permit(:clinics)
  end
  # end of private
end
