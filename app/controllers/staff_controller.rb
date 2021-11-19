# Staff is just an aliased for Users i.e. staff are nothing but users
# so User model itself using as staff
class StaffController < ApplicationController
  def index
    @staff = User.order(:first_name)
    render json: @staff
  end
end
