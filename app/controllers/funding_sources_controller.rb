class FundingSourcesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_clinic

  def index
    @funding_sources = FundingSource.all
  end

  def create
    @funding_source = @clinic.funding_sources.create(funding_source_params)
  end

  private

  def funding_source_params
    params.permit(:name, :aka, :title, :status)
  end

  def set_clinic
    @clinic = Clinic.find(params[:clinic_id])
  end

end
