class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_organization, only: %i[update show destroy remove_region]

  def index
    @organizations = Organization.order(:name)
    @organizations = @organizations&.paginate(page: params[:page]) if params[:page].present?
  end

  def show
    @organization
  end

  def create
    @organization = Organization.new(organization_params)
    @organization.admin_id = current_user.id
    @organization.save
  end

  def update
    @organization&.update(organization_params)
  end

  def destroy
    @organization&.destroy
  end

  def regions_organizations
    @organization = Organization.find_by(id: params[:id]) 
    @regions = @organization.regions if @organization.present?
  end

  def remove_region
    @remove_region = @organization.delete_region(params[:region].to_i)
  end

  private

  def organization_params
    params.permit(:name, :aka, :web, :email, :status, address_attributes: 
    %i[line1 line2 line3 zipcode city state country addressable_type addressable_id],
    phone_number_attributes: %i[phone_type number], id_regions: [])
  end

  def set_organization
    @organization = Organization.find(params[:id]) rescue nil
  end

  def authorize_user
    authorize Organization if current_user.role_name!='super_admin'
  end
end
