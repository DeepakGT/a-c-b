class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, only: %i[super_admins_list create_super_admin]

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

  def create_super_admin
    @super_admin = User.new(create_params)
    @super_admin.role = Role.find_by(name: 'super_admin')
    @super_admin.save
  end

  private

  def create_params
    params.permit(:email, :first_name, :last_name, :dob, :terminated_on, :gender, :hired_at, ).merge({password: 'Welcome1234!', password_confirmation: 'Welcome1234!'})
  end

  def authorize_user
    authorize User
  end
end
