require 'will_paginate/array'
class StaffController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: %i[phone_types supervisor_list gender_list]
  before_action :set_staff, only: %i[show update destroy]
  before_action :remove_trailing_space, only: %i[create update]

  def index
    staff = Staff.all
    staff = do_filter(staff) if params[:search_value].present?
    staff = filter_by_status(staff)
    staff = filter_by_location(staff) 
    @staff = staff&.uniq&.sort_by(&:first_name)
    @staff = @staff&.paginate(page: params[:page]) if params[:page].present?
  end

  def show
    @staff
  end

  def update
    set_role if params[:role_name].present?
    set_password
    @staff&.update(staff_params)
  end
  
  def create
    @staff = Staff.new(staff_params)
    set_role
    @staff&.save
    set_home_clinic if !@staff&.id.nil?
  end

  def destroy
    @staff&.destroy
  end

  def phone_types
    @phone_types = PhoneNumber.phone_types
  end

  def supervisor_list
    @supervisors = Staff.order(:first_name)
  end

  def gender_list
    success_response(Staff.transform_genders)
  end

  private

  def staff_params
    arr = %i[first_name last_name gender hired_at terminated_on email supervisor_id job_type legacy_number npi deactivated_at]
    
    arr.concat(%i[password password_confirmation]) if params[:action] == 'create'
    
    arr.concat([address_attributes: 
    %i[line1 line2 line3 zipcode city state country addressable_type addressable_id], 
    phone_numbers_attributes: %i[id phone_type number], rbt_supervision_attributes: 
    %i[status start_date end_date]])
    
    params.permit(arr)
  end

  def set_role
    @staff&.role = Role.find_by(name: params[:role_name])
  end

  def set_staff
    @staff = Staff.find(params[:id]) rescue nil
  end

  def set_password
    return if params[:password].blank? || params[:password_confirmation].blank?
    
    @staff&.password = params[:password]
    @staff&.password_confirmation = params[:password_confirmation]
  end

  def set_home_clinic
    return if params[:staff_location_id].blank?

    @staff&.staff_clinics&.create(clinic_id: params[:staff_location_id], is_home_clinic: true)
  end

  def do_filter(staff)
    if params[:search_by].present?
      case params[:search_by]
      when "name"
        fname, lname = params[:search_value].split(' ')
        if fname.present? && lname.blank?
          staff = staff.by_first_name(fname).or(staff.by_last_name(fname))
        else
          staff = staff.by_first_name(fname) 
          staff = staff.by_last_name(lname) 
        end
        return staff
      when "organization"
        staff.joins(clinics: :organization).by_organization(params[:search_value])
      when "role"
        staff.joins(:role).by_role(params[:search_value])
      when "immediate_supervisor"
        fname, lname = params[:search_value].split
        if lname.present?
          staff.by_supervisor_full_name(fname, lname)
        else
          staff.by_supervisor_first_name(fname).or(staff.by_supervisor_last_name(fname))
        end
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
    fname, lname = query.split
    if lname.present?
      staff = staff.by_first_name(fname).by_last_name(lname)
                   .or(staff.by_organization(query))
                   .or(staff.by_role(query))
                   .or(staff.by_supervisor_full_name(fname,lname))
    else
      staff = staff.by_first_name(fname)
                   .or(staff.by_last_name(fname))
                   .or(staff.by_organization(query))
                   .or(staff.by_role(query))
                   .or(staff.by_supervisor_first_name(fname))
                   .or(staff.by_supervisor_last_name(fname))
    end
    staff
  end

  def authorize_user
    authorize Staff if current_user.role_name!='super_admin'
  end

  def filter_by_location(staff)
    if params[:default_location_id].present? && params[:search_cross_location]!=1 && params[:search_cross_location]!="1" 
      location_id = params[:default_location_id]
      staff = staff.by_home_clinic(location_id)
    end
    staff
  end

  def filter_by_status(staff)
    if params[:show_inactive]=="1" || params[:show_inactive]==1
      staff = staff.inactive
    else
      staff = staff.active
    end
  end

  def remove_trailing_space
    params[:first_name].strip! if params[:first_name].present?
    params[:last_name].strip! if params[:last_name].present?
  end
  # end of private
end
