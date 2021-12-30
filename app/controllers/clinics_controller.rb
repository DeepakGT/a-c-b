class ClinicsController < ApplicationController
  before_action :authenticate_user!

  def index
    @clinics = Clinic.order(:name).paginate(page: params[:page])
  end

  def create
    @clinic = Clinic.create(clinic_params)
  end

  private

  def clinic_params
    params.permit(:name, :organization_id, :aka, :web, :email, :status, address_attributes: 
    %i[line1 line2 line3 zipcode city state country addressable_type addressable_id],
    phone_number_attributes: %i[phone_type number])
  end
end
