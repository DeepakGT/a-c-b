class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization, only: %i[update show]

  def index
    @organizations = Organization.order(:name).paginate(page: params[:page])
  end

  def show; end

  def create
    @organization = Organization.new(organization_params)
    @organization.admin_id = current_user.id
    @organization.save
  end

  def update
    @organization.update(organization_params)
  end

  private

  def organization_params
    params.permit(:name, :aka, :web, :email, :status, address_attributes: 
    %i[line1 line2 line3 zipcode city state country addressable_type addressable_id],
    phone_numbers_attributes: %i[phone_type number])
  end

  def set_organization
    @organization = Organization.find(params[:id])
  end
  # end of private

end
