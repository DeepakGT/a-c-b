class FundingSourcesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_clinic
  before_action :set_funding_source, only: %i[show update destroy]

  def index
    @funding_sources = @clinic.funding_sources.order(:name).paginate(page: params[:page])
  end

  def show; end

  def create
    @funding_source = @clinic.funding_sources.new(funding_source_params)
    @funding_source.save
  end

  def update
    @funding_source.update(funding_source_params)
  end

  def destroy
    @funding_source.destroy
  end

  private

  def funding_source_params
    params.permit(:name, :plan_name, :payor_type, :email, :notes, :network_status, :status, address_attributes: 
                  %i[line1 line2 line3 zipcode city state country addressable_type addressable_id],
                  phone_number_attributes: %i[phone_type number])
  end

  def set_clinic
    @clinic = Clinic.find(params[:clinic_id])
  end

  def set_funding_source
    @funding_source = @clinic.funding_sources.find(params[:id])
  end

  def authorize_user
    authorize FundingSource if current_user.role_name!='super_admin'
  end
  # end of private
  
end
