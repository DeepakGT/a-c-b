# Staff is just an aliased for Users i.e. staff are nothing but users
# so User model itself using as staff
class QualificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_clinic_staff

  def create
    @qualification = @staff.qualification.new(qualification_params)
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
    params.permit!(:tb_cleared_at, :doj_cleared_at, :fbi_cleared_at, :tb_expires_at, :doj_expires_at, :fbi_expires_at, :credential_id, :funding_source_id)
  end

  def set_clinic_staff
    clinic = Clinic.find(params[:clinic_id])
    @staff = clinic.staff.find(params[:staff_id])
  end

  # end of private
end
