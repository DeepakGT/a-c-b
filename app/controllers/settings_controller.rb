class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_setting

  def show; end

  def update 
    @setting.update(update_params)
  end

  private

  def update_params
    params.permit(:welcome_note, roles_ids:[])
  end

  def set_setting
    @setting = Setting.first
  end

  def authorize_user
    authorize Setting if current_user.role_name!='super_admin'
  end
end
