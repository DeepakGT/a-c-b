class ClinicsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_clinic, only: %i[show update destroy]

  def index
    @clinics = Clinic.all
    @clinics = @clinics&.by_org_id(params[:organization_id]) if params[:organization_id].present?
    @clinics = @clinics&.order(:name)
    @clinics = @clinics&.paginate(page: params[:page]) if params[:page].present?
  end

  def create
    @clinic = Clinic.new(clinic_params)
    @clinic.save ? @clinic : unprosessable_entity_response(@clinic)
  end

  def show; end

  def update
    unprosessable_entity_response(@clinic) unless @clinic.update(clinic_params)
  end

  def destroy
    unless current_user.role_name == 'super_admin'
      @clinic&.errors&.add(:clinic, "You are not authorized to destroy the location.")
    else
      @clinic&.clients&.present? || @clinic&.staff&.present? ? @clinic&.errors&.add(:clinic, "cannot be removed since it has clients and staffs associated with it.") : @clinic&.destroy
    end
  end

  def massive_region
    if Clinic.change_region(params[:region], params[:locations])
      render json: { status: 'success', messages: I18n.t('.controllers.clinics.success_massive').capitalize }, status: :ok
    else
      render json: { status: 'error', messages: I18n.t('.controllers.clinics.errors_massive').capitalize }, status: :bad_request
    end
  end

  private

  def set_clinic
    @clinic = Clinic.find(params[:id]) rescue nil
  end

  def clinic_params
    params.permit(:name, :organization_id, :aka, :web, :email, :status, :region_id, address_attributes: 
    %i[line1 line2 line3 zipcode city state country addressable_type addressable_id],
    phone_number_attributes: %i[phone_type number])
  end

  def authorize_user
    authorize Clinic if current_user.role_name!='super_admin'
  end
  # end of private
  
end
