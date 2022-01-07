class FundingSourcesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_clinic

  def index
    @funding_sources = @clinic.funding_sources.paginate(page: params[:page])
  end

  def create
    @funding_source = @clinic.funding_sources.new(funding_source_params)
    authorize @funding_source
    @funding_source.save
  end

  def update
    @funding_source = @clinic.funding_sources.find(params[:id])
    authorize @funding_source
    @funding_source.update(funding_source_params)
  end

  private

  def funding_source_params
    params.permit(:name, :plan_name, :payer_type, :email, :notes, :network_status, address_attributes: 
                  %i[line1 line2 line3 zipcode city state country addressable_type addressable_id],
                  phone_number_attributes: %i[phone_type number])
  end

  def set_clinic
    @clinic = Clinic.find(params[:clinic_id])
  end

end
