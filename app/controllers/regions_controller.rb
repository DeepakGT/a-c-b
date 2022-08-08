class RegionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @regions = Region.all
  end
end
