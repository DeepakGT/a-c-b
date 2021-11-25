class ClinicsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization

  def index
    @clinics = @organization.clinics.order(:name).paginate(page: params[:page])
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

end
