require 'will_paginate/array'

class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.newest_first.unread
    @notifications = @notifications&.paginate(page: params[:page], :per_page => params[:per_page]) if params[:page].present?
  end

  def set_notifications_read
    if params[:ids].present?
      current_user.mark_notifications_as_read(notification_params[:ids])
      render json: { success: true }, status: :ok
    else
      render json: { success: false, error: I18n.t("application_controller.controllers.notification.messages.error").capitalize }, status: :forbidden
    end
  rescue => e
    render json: { success: false, error: e.message }, status: :not_found
  end

  private

  def notification_params
    params.permit(ids: [])
  end
end
