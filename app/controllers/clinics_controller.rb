class ClinicsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_clinic, only: %i[show update destroy]

  def index
    @clinics = Clinic.all
    @clinics = @clinics.by_org_id(params[:organization_id]) if params[:organization_id].present?
    @clinics = @clinics.order(:name)
    @clinics = @clinics.paginate(page: params[:page]) if params[:page].present?
  end

  def create
    @clinic = Clinic.new(clinic_params)
    @clinic.id = Clinic.ids.max+1 if Clinic.ids.present?
    @clinic.save
  end

  def show; end

  def update
    @clinic.update(clinic_params)
  end

  def destroy
    unless current_user.role_name == 'super_admin'
      @clinic.errors.add(:clinic, "You are not authorized to destroy the location.")
      throw(:abort)
    else
      @clinic.clients.present? || @clinic.staff.present? ? @clinic.errors.add(:clinic, "cannot be removed since it has clients and staffs associated with it.") : @clinic.destroy
    end
  end

  private

  def set_clinic
    @clinic = Clinic.find(params[:id])
  end

  def clinic_params
    params.permit(:name, :organization_id, :aka, :web, :email, :status, address_attributes: 
    %i[line1 line2 line3 zipcode city state country addressable_type addressable_id],
    phone_number_attributes: %i[phone_type number])
  end

  def authorize_user
    authorize Clinic if current_user.role_name!='super_admin'
  end
  # end of private
  
end
