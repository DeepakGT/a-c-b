class RegionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_region, only: %I[update]
  before_action :authorize_user

  def index
    @regions = Region.all
  end
  
  def create
    @region = Region.new(regions_params)
    @region.save ? @region : unprosessable_entity_response(@region)
  end

  def update
    @region.update(regions_params) ? @region : unprosessable_entity_response(@region)
  end
  
  private

  def set_region
    @region = Region.find(params[:id]) rescue nil
  end
  
  def regions_params
    params.permit(:name)
  end
  
  def authorize_user
    authorize Region if current_user.role_name != Constant.super_admin
  end
end
  