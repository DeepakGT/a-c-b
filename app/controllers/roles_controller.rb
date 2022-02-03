class RolesController < ApplicationController
  before_action :authenticate_user!
  # before_action :authorize_user, except: :roles_list

  def index
    @roles = Role.all
  end

  def create
    @role = Role.create(role_params)
  end

  def update
    @role = Role.find(params[:id])
    @role.update(permissions: params[:permissions])
    @role.update(name: params[:name]) if params[:change_role_name].present? && params[:change_role_name]
  end

  def roles_list
    @roles = Role.where.not(name: 'super_admin')
  end

  private

  def role_params
    params.permit(%i[name permissions])
  end

  def authorize_user
    authorize Role if current_user.role_name!='super_admin'
  end
  # end of private
  
end
