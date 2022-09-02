class UsersController < ApplicationController
  before_action :authenticate_user!

  def current_user_detail
    @user = current_user
  end

  def update_default_schedule_view
    @user = current_user
    @user.update(default_schedule_view: params[:default_schedule_view])
  end

  def email_notifications
    @user = User.find(email_notification_params[:user_id]) rescue nil
    @user.update(deactive_at: email_notification_params[:deactive_at])
  end

  private

  def email_notification_params
    params.permit(:user_id, :deactive_at)
  end
end
