class UsersController < ApplicationController
  before_action :authenticate_user!

  def current_user_detail
    @user = current_user
  end

  def update_default_schedule_view
    @user = current_user
    @user.update(default_schedule_view: params[:default_schedule_view])
  end
end
