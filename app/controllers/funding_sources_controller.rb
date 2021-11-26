class FundingSourcesController < ApplicationController
  before_action :authenticate_user!

  def index
    @funding_sources = FundingSource.all
  end

end
