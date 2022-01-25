class StaffController < ApplicationController
  before_action :authenticate_user!
  before_action :set_clinic, only: %i[create supervisor_list]
  before_action :set_staff, only: %i[show update]

  def index
    staff = Staff.all
    staff = do_filter(staff) if params[:search_value].present?
    @staff = staff.order(:first_name).paginate(page: params[:page])
  end

  def show; end

  def update
    set_role if params[:role_name].present?
    @staff.update(staff_params)
  end
  
  def create
    @staff = @clinic.staff.new(staff_params)
    set_role
    @staff.save
  end

  def supervisor_list
    @supervisors = @clinic.staff.order(:first_name)
  end

  private

  def set_clinic
    @clinic = Clinic.find(params[:clinic_id])
  end

  def staff_params
    arr = %i[first_name last_name status terminated_at email supervisor_id clinic_id]
    
    arr.concat(%i[password service_provider password_confirmation]) if params[:action] == 'create'
    
    arr.concat([address_attributes: 
    %i[line1 line2 line3 zipcode city state country addressable_type addressable_id], 
    phone_numbers_attributes: %i[id phone_type number], rbt_supervision_attributes: 
    %i[status start_date end_date], services_attributes: %i[name status display_code]])
    
    params.permit(arr)
  end

  def set_role
    @staff.role = Role.send(params[:role_name]).first
  end

  def set_staff
    @staff = Staff.find(params[:id])
  end

  def do_filter(staff)
    if params[:search_by].present?
      case params[:search_by]
      when "name"
        fname, lname = params[:search_value].split(' ')
        staff = staff.by_first_name(fname) if fname.present?
        staff = staff.by_last_name(lname) if lname.present?
        return staff
      when "organization"
        staff.joins(clinic: :organization).by_organization(params[:search_value])
      when "title"
        staff.joins(:role).by_role(params[:search_value])
      when "immediate_supervisor"
        fname, lname = params[:search_value].split
        staff.by_supervisor_name(fname, lname)
      when "location"
        location = params[:search_value].split.map{|x| "%#{x}%"}
        staff.joins(:address).by_location(location)
      else
        staff
      end
    else
      search_on_all_fields(params[:search_value])
    end
  end

  def search_on_all_fields(value)
    staff = Staff.includes(:role, :address, clinic: :organization).all
    formated_val = value.split.map{|x| "%#{x}%"}
    fname, lname = value.split
    staff.by_first_name(fname).by_last_name(lname)
         .or(staff.by_organization(value))
         .or(staff.by_role(value))
         .or(staff.by_supervisor_name(fname,lname))
         .or(staff.by_location(formated_val))
  end
  # end of private
end
