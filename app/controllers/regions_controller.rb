class RegionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_region, only: %I[update]
  before_action :authorize_user

  def index
    @regions = Region.order(:name)
    @regions = @regions.paginate(page: params[:page]) if params[:page].present?
  end
  
  def create
    @region = Region.new(regions_params)
    unprosessable_entity_response(@region) unless @region.save
  end

  def update
    unprosessable_entity_response(@region) unless @region.update(regions_params) 
  end
  
  private

  def set_region
    @region = Region.find(params[:id]) rescue nil
  end
  
  def regions_params
    params.permit(:name)
  end
  
  def authorize_user
    authorize Region
  end
end
  