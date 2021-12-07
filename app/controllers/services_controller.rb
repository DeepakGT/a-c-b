class ServicesController < ApplicationController
  before_action :authenticate_user!

  def index
    @services = Service.order(:name)
  end

  def create
    @service = Service.create(service_params)
  end

  private

  def service_params
    params.permit(:name, :status, :default_pay_code, :category, :display_code, :tracking_id)
  end
  # end of private

end
