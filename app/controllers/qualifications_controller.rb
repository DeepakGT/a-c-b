class QualificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_staff

  def create
    @qualification = Qualification.create_with(staff_id: @staff.id).new(qualification_params)
    @qualification.save
  end

  def update
    @qualification = @staff.qualification
    return if @qualification.blank?

    @qualification.update(qualification_params)
  end

  def show
    @qualification = @staff.qualification
  end

  private

  def qualification_params
    params.permit(:tb_cleared_at, :doj_cleared_at, :fbi_cleared_at, :tb_expires_at, :doj_expires_at, 
                  :fbi_expires_at, qualifications_credentials_attributes: %i[credential_id issued_at expires_at cert_lic_number documentation_notes])
  end

  def set_staff
    @staff = User.find(params[:staff_id])
  end

  # end of private
end
