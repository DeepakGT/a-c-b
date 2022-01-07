# Staff is just an aliased for Users i.e. staff are nothing but users
# so User model itself using as staff
class StaffController < ApplicationController
  before_action :authenticate_user!
  before_action :set_clinic, only: %i[create supervisor_list]

  def index
    @staff = User.joins(:role).by_staff_roles
    if params[:search_by].present?
      if params[:search_by]=="name"
        fname, lname = params[:search_value].split(' ')
        @staff = @staff.by_first_name(fname) if fname.present?
        @staff = @staff.by_last_name(lname) if lname.present?
      elsif params[:search_by]=="organization"
        @staff = @staff.joins(clinic: :organization).by_organization(params[:search_value])
      elsif params[:search_by]=="title"
        @staff = @staff.joins(:role).by_role(params[:search_value])
      elsif params[:search_by]=="immediate_supervisor"
        fname, lname = params[:search_value].split
        @staff = @staff.by_supervisor_name(fname, lname)
      elsif params[:search_by]=="location"
        location = params[:search_value].split.map{|x| "%#{x}%"}
        @staff = @staff.joins(:address).by_location(location)
      end
    elsif params[:search_value].present?
      @staff = search_by_all_fields(params[:search_value])
    end
    @staff = @staff.order(:first_name).paginate(page: params[:page])
  end

  def show
    @staff = User.find(params[:id])
  end

  def update
    @staff = User.find(params[:id])
    set_role if params[:role_name].present?
    @staff.update(staff_params)
  end
  
  def create
    @staff = @clinic.staff.new(create_params)
    set_role
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
                  :clinic_id, address_attributes: 
                  %i[line1 line2 line3 zipcode city state country addressable_type addressable_id], 
                  phone_numbers_attributes: %i[phone_type number], user_role_attributes: [role_attributes: %i[name]])
  end

  def create_params
    params.permit(:first_name, :last_name, :status, :terminated_at, :email, :password,
                  :service_provider, :password_confirmation, :supervisor_id, :clinic_id, address_attributes: 
                  %i[line1 line2 line3 zipcode city state country addressable_type addressable_id], 
                  phone_numbers_attributes: %i[phone_type number], rbt_supervision_attributes: 
                  %i[status start_date end_date], services_attributes: %i[name status display_code])
  end

  def set_role
    @staff.role = Role.send(params[:role_name]).first
  end

  def search_by_all_fields(value)
    @staff = User.includes(:role, :address, clinic: :organization).by_staff_roles
    val = value.split.map{|x| "%#{x}%"}
    fname, lname = value.split
    @staff = @staff.by_first_name(fname).by_last_name(lname).or(@staff.by_organization(value)).or(@staff.by_role(value)).or(@staff.by_supervisor_name(fname,lname)).or(@staff.by_location(val))
    return @staff
  end
  # end of private
end
