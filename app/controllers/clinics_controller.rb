class ClinicsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_clinic, only: %i[show update]

  def index
    @clinics = Clinic.all
    @clinics = @clinics.by_org_id(params[:organization_id]) if params[:organization_id].present?
    @clinics = @clinics.order(:name).paginate(page: params[:page])
  end

  def create
    @clinic = Clinic.create(clinic_params)
  end

  def show; end

  def update
    @clinic.update(clinic_params)
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
end
