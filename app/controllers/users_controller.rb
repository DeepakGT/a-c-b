class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, only: %i[super_admins_list create_super_admin super_admin_detail update_super_admin]

  def current_user_detail
    @user = current_user
  end

  def update_default_schedule_view
    @user = current_user
    @user.update(default_schedule_view: params[:default_schedule_view])
  end

  def super_admins_list
    @super_admins = User.by_roles('super_admin')
    @super_admins = @super_admins.paginate(page: params[:page]) if params[:page].present?
  end

  def create_super_admin
    @super_admin = User.new(create_params)
    @super_admin.role = Role.find_by(name: 'super_admin')
    @super_admin.save
  end

  def super_admin_detail
    @super_admin = User.find(params[:id]) rescue nil
  end
  
  def update_super_admin
    @super_admin = User.find(params[:id]) rescue nil
    @super_admin&.update(update_params)
  end

  private

  def create_params
    params.permit(:email, :first_name, :last_name, :dob, :terminated_on, :gender, :hired_at, :status).merge({password: 'Welcome1234!', password_confirmation: 'Welcome1234!'})
  end

  def authorize_user
    authorize User
  end

  def update_params
    params.permit(:email, :first_name, :last_name, :dob, :terminated_on, :gender, :hired_at, :password, :password_confirmation, :status)
  end
end
