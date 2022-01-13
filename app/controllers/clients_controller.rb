class ClientsController < ApplicationController
  before_action :authenticate_user!

  def index
    @clients = Client.order(:first_name)
  end
end
