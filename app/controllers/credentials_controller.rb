class CredentialsController < ApplicationController
  before_action :authenticate_user!

  def index
    @credentials = Credentials.all
  end

end
