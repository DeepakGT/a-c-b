class RegionsController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_region, only: %I[update]

  def index
    @regions = Region.all
  end
  
  def create
    @region = Region.new(regions_params)
    if @region.save
      render json: {status: 'success', data: [id: @region.id, name: @region.name]}, status: :ok
    else
      render json: {status: 'errors', errors: @region.errors.full_messages}, status: :bad_request
    end
  end

  def update
    if @region.update_attributes(regions_params)
      redirect_to @object
    else
      render 'edit'
    end
  end
  
  
  private

  def set_region
    @region = Region.find(params[:id]) rescue nil
  end
  

  def regions_params
    params.permit(:name)
  end
end
