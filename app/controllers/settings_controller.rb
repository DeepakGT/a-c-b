class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_setting

  def show; end

  def update 
    @setting.update(welcome_note: params[:welcome_note])
  end

  private

  def set_setting
    @setting = Setting.first
  end
end
