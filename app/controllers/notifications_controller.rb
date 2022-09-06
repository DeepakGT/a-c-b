require 'will_paginate/array'

class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.newest_first.unread
    @notifications = @notifications&.paginate(page: params[:page], :per_page => params[:per_page]) if params[:page].present?
  end

  def set_notifications_read
    if params[:ids].present?
      current_user.notifications.by_ids(params[:ids]).mark_as_read!
      render json: { success: true }, status: 200
    else
      render json: { success: false, error: 'The :ids parameter must have at minimum a valid numeric value' }, status: 400
    end
  rescue => e
    render json: { success: false, error: e.message }, status: 400
  end
end
