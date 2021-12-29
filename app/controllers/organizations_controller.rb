class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization, only: %i[update show]

  def index
    @organizations = Organization.all
  end

  def show; end

  def create
    @organization = Organization.new(name: params[:name], admin_id: current_user.id)
    @organization.save
  end

  def update
    @organization.update(name: params[:name])
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end
  # end of private

end
