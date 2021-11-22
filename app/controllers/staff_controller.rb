# Staff is just an aliased for Users i.e. staff are nothing but users
# so User model itself using as staff
class StaffController < ApplicationController
  before_action :set_clinic

  def index
    staff = @clinic.staff.order(:first_name)
    render json: staff
  end

  def show
    staff = @clinic.staff.find(params[:id])
    render json: staff, serializer: CompleteStaffSerializer
  end

  private

  def set_clinic
    @clinic = Clinic.find(params[:clinic_id])
  end

  # end of private
end
