class CredentialsController < ApplicationController
  before_action :authenticate_user!

  def index
    @credentials = Credential.all
  end

  def create
    @credential = Credential.create(credential_params)
  end

  def show
    @credential = Credential.find(params[:id])
  end

  def update
    @credential = Credential.find(params[:id])
    @credential.update(credential_params)
  end

  private

  def credential_params
    params.permit(:credential_type, :name, :description, :lifetime)
  end

  # end of private

end
