class StaffCredentialsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_staff

  def index
    @credentials = @staff.credentials
  end

  def create
    @staff_credential = @staff.staff_credentials.new(staff_credential_params)
    @staff_credential.save
  end

  private

  def set_staff
    @staff = User.find(params[:staff_id])
  end

  def staff_credential_params
    params.permit(:credential_id, :issued_at, :expires_at, :cert_lic_number, :documentation_notes)
  end

  # end of private

end
