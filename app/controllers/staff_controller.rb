# Staff is just an aliased for Users i.e. staff are nothing but users
# so User model itself using as staff
class StaffController < ApplicationController
  before_action :authenticate_user!
  before_action :set_clinic, only: %i[create supervisor_list]

  def index
    @staff = User.joins(:role).by_staff_roles
    if params[:name].present? 
      fname, lname = params[:name].split(' ')
      @staff = @staff.by_name(fname,lname)
    end
    @staff = @staff.joins(clinic: :organization).by_organization(params[:organization]) if params[:organization].present?
    @staff = @staff.joins(:role).by_role(params[:title]) if params[:title].present?
    if params[:immediate_supervisor].present?
      fname, lname = params[:immediate_supervisor].split
      @staff = @staff.by_supervisor_name(fname, lname)
    end
    if params[:location].present?
      location = params[:location].split.map{|x| "%#{x}%"}
      @staff = @staff.by_location(location)
    end
    @staff = @staff.order(:first_name).paginate(page: params[:page])
  end

  def show
    @staff = User.find(params[:id])
  end

  def update
    @staff = User.find(params[:id])
    @staff.update(staff_params)
  end
  
  def create
    @staff = @clinic.staff.new(create_params)
    @staff.role = Role.bcba.first
    @staff.save
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
    params.permit(:first_name, :last_name, :status, :terminated_at, :email, :supervisor_id, 
                  :clinic_id,address_attributes: 
                  %i[line1 line2 line3 zipcode city state country addressable_type addressable_id], 
                  phone_numbers_attributes: %i[phone_type number])
  end

  def create_params
    params.permit(:first_name, :last_name, :status, :terminated_at, :email, :password,
                  :service_provider, :password_confirmation, :supervisor_id, :clinic_id, address_attributes: 
                  %i[line1 line2 line3 zipcode city state country addressable_type addressable_id], 
                  phone_numbers_attributes: %i[phone_type number], rbt_supervision_attributes: 
                  %i[status start_date end_date], services_attributes: %i[name status display_code])
  end
  # end of private
end
