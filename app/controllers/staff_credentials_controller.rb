class StaffCredentialsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_staff
  before_action :set_staff_credential, only: %i[show update destroy]

  def index
    @credentials = @staff.credentials
  end

  def create
    @staff_credential = @staff.staff_credentials.new(staff_credential_params)
    @staff_credential.save
  end

  def show; end

  def update
    @staff_credential.update(staff_credential_params)
  end

  def destroy
    @staff_credential.destroy
  end

  private

  def staff_credential_params
    params.permit(:credential_id, :issued_at, :expires_at, :cert_lic_number, :documentation_notes)
  end

  def set_staff
    @staff = User.find(params[:staff_id])
  end

  def set_staff_credential
    @staff_credential = @staff.staff_credentials.find(params[:id])
  end

  # end of private

end
