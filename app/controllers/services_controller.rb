class ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_service, only: :update

  def index
    @services = Service.order(:name)
  end

  def create
    @service = Service.create(service_params)
  end

  def update
    @service.update(service_params)
  end

  private

  def service_params
    params.permit(:name, :status, :default_pay_code, :category, :display_code, :tracking_id)
  end

  def set_service
    @service = Service.find(params[:id])
  end
  # end of private

end
