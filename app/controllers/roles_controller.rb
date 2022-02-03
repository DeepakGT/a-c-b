class RolesController < ApplicationController
  before_action :authenticate_user!

  def index
    @roles = Role.all
  end

  def create
    @role = Role.create(role_params)
  end

  def roles_list
    @roles = Role.all
  end

  private

  def role_params
    params.permit(%i[name permissions])
  end
  # end of private
  
end
