class UsersController < ApplicationController
  before_action :authenticate_user!

  def current_user_detail
    @user = current_user
  end

  def update_default_schedule_view
    @user = current_user
    @user.update(default_schedule_view: params[:default_schedule_view])
  end

  def super_admins_list
    @super_admins = User.by_roles('super_admin')
  end
end
