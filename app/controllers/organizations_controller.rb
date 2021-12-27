class OrganizationsController < ApplicationController
  before_action :authenticate_user!

  def create
    @organization = Organization.new(name: params[:name], admin_id: current_user.id)
    @organization.save
  end

end
