class UsersController < ApplicationController
  before_action :authenticate_user!

  def current_user_detail
    @user = current_user
  end
end
