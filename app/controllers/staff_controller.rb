# Staff is just an aliased for Users i.e. staff are nothing but users
# so User model itself using as staff
class StaffController < ApplicationController
  before_action :authenticate_user!
  before_action :set_clinic, except: :phone_types

  def index
    @staff = @clinic.staff.order(:first_name).paginate(page: params[:page])
  end

  def show
    @staff = @clinic.staff.find(params[:id])
  end

  def update
    @staff = @clinic.staff.find(params[:id])
    @staff.update(staff_params)
  end

  def phone_types
    @phone_types = PhoneNumber.phone_types
  end

  def supervisor_list
    @supervisors = @clinic.staff.order(:first_name)
  end

  private

  def set_clinic
    @clinic = Clinic.find(params[:clinic_id])
  end

  def staff_params
    params.permit(:first_name, :last_name, :hired_at, :status, :terminated_at, :email, :password,
                  :password_confirmation, :supervisor_id, :clinic_id,address_attributes: 
                  %i[line1 line2 line3 zipcode city state country addressable_type addressable_id],
                  phone_numbers_attributes: %i[phone_type number])
  end

  # end of private
end
