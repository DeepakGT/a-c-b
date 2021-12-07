class ServicesController < ApplicationController
  before_action :authenticate_user!

  def index
    @services = Service.order(:name)
  end

end
