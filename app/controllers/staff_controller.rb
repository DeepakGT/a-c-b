require 'will_paginate/array'
class StaffController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: %i[phone_types supervisor_list]
  before_action :set_staff, only: %i[show update destroy]

  def index
    staff = Staff.all
    staff = do_filter(staff) if params[:search_value].present?
    staff = filter_by_location(staff) if params[:default_location_id].present?
    @staff = staff.uniq.sort_by(&:first_name).paginate(page: params[:page])
  end

  def show; end

  def update
    set_role if params[:role_name].present?
    set_password
    @staff.update(staff_params)
  end
  
  def create
    @staff = Staff.new(staff_params)
    set_role
    @staff.save
    set_home_clinic
  end

  def destroy
    @staff.destroy
  end

  def phone_types
    @phone_types = PhoneNumber.phone_types
  end

  def supervisor_list
    @supervisors = Staff.order(:first_name)
  end

  private

  def staff_params
    arr = %i[first_name last_name hired_on terminated_on email supervisor_id job_type]
    
    arr.concat(%i[password password_confirmation]) if params[:action] == 'create'
    
    arr.concat([address_attributes: 
    %i[line1 line2 line3 zipcode city state country addressable_type addressable_id], 
    phone_numbers_attributes: %i[id phone_type number], rbt_supervision_attributes: 
    %i[status start_date end_date]])
    
    params.permit(arr)
  end

  def set_role
    @staff.role = Role.find_by(name: params[:role_name])
  end

  def set_staff
    @staff = Staff.find(params[:id])
  end

  def set_password
    return if params[:password].blank? || params[:password_confirmation].blank?
    
    @staff.password = params[:password]
    @staff.password_confirmation = params[:password_confirmation]
  end

  def set_home_clinic
    return if params[:staff_location_id].blank?

    @staff.staff_clinics.create(clinic_id: params[:staff_location_id], is_home_clinic: true)
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
        staff.joins(clinics: :organization).by_organization(params[:search_value])
      when "role"
        staff.joins(:role).by_role(params[:search_value])
      when "immediate_supervisor"
        fname, lname = params[:search_value].split
        staff.by_supervisor_name(fname, lname)
      when "location"
        staff.joins(:address).by_location(params[:search_value])
      else
        staff
      end
    else
      search_on_all_fields(params[:search_value])
    end
  end

  def search_on_all_fields(query)
    staff = Staff.left_joins(:role, :address, clinics: :organization).all
    # formated_val = query.split.map{|x| "%#{x}%"}
    fname, lname = query.split
    staff = staff.by_first_name(fname).by_last_name(lname)
                 .or(staff.by_organization(query))
                 .or(staff.by_role(query))
                 .or(staff.by_supervisor_name(fname,lname))
                 .or(staff.by_location(query))
  end

  def authorize_user
    authorize Staff if current_user.role_name!='super_admin'
  end

  def filter_by_location(staff)
    location_id = params[:default_location_id]
    staff = staff.by_clinic(location_id)
  end
  # end of private
end
