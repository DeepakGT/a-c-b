class StaffQualificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_staff
  before_action :set_staff_qualification, only: %i[show update destroy]

  def index
    @qualifications = @staff.qualifications.order(:created_at)
  end

  def create
    @staff_qualification = @staff.staff_qualifications.create(staff_qualification_params)
  end

  def show
    @staff_qualification
  end

  def update
    @staff_qualification.update(staff_qualification_params)
  end

  def destroy
    @staff_qualification.destroy
  end

  private

  def staff_qualification_params
    params.permit(:credential_id, :issued_at, :expires_at, :cert_lic_number, :documentation_notes)
  end

  def set_staff
    @staff = Staff.find(params[:staff_id])
  end

  def set_staff_qualification
    @staff_qualification = @staff.staff_qualifications.find(params[:id])
  end

  def authorize_user
    authorize StaffQualification if current_user.role_name!='super_admin'
  end
  # end of private

end
