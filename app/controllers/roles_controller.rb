class RolesController < ApplicationController
  before_action :authenticate_user!
  # before_action :authorize_user, except: :roles_list
  before_action :set_role, only: %i[show update]

  def index
    @roles = Role.order(:name).paginate(page: params[:page])
  end

  def show; end

  def create
    @role = Role.create(name: params[:name], permissions: params[:permissions])
  end

  def update
    params_to_update = {permissions: params[:permissions]}
    params_to_update.merge!(name: params[:name]) if params[:change_role_name].to_bool.true?
    @role.update(params_to_update)
  end

  def roles_list
    @roles = Role.where.not(name: 'super_admin')
  end

  private

  def authorize_user
    authorize Role if current_user.role_name!='super_admin'
  end

  def set_role
    @role = Role.find(params[:id])
  end
  # end of private
  
end
