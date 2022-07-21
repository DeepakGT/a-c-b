class RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: :roles_list
  before_action :set_role, only: %i[show update destroy]

  def index
    @roles = Role.order(:name)
    @roles = @roles.paginate(page: params[:page]) if params[:page].present?
  end

  def show; end

  def create
    @role = Role.create(name: params[:name], permissions: params[:permissions], id: Role.ids.max+1)
  end

  def update
    params_to_update = {permissions: params[:permissions]}
    params_to_update.merge!(name: params[:name]) if params[:change_role_name].to_bool.true?
    @role.update(params_to_update)
  end

  def destroy
    @role.destroy
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
