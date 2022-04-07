require 'will_paginate/array'
class SchedulingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_scheduling, only: %i[show update destroy]
  before_action :set_client_enrollment_service, only: :create

  def index
    schedules = Scheduling.all
    schedules = do_filter(schedules)
    @schedules = schedules.uniq.sort_by(&:date).paginate(page: params[:page])
  end

  def show; end

  def create
    @schedule = @client_enrollment_service.schedulings.new(scheduling_params)
    @schedule.creator_id = current_user.id
    @schedule.user = current_user
    @schedule.save
  end

  def update
    @schedule.user = current_user
    @schedule.update(scheduling_params)
    @schedule.updator_id = current_user.id
    update_render_service if params[:is_rendered].present?
    update_client_enrollment_service if params[:client_enrollment_service_id].present?
    @schedule.save
  end

  def destroy
    @schedule.destroy
  end

  private

  def authorize_user
    authorize Scheduling if current_user.role_name!='super_admin'
  end

  def scheduling_params
    params.permit(:staff_id, :status, :date, :start_time, :end_time, :units, :minutes, 
                  :client_enrollment_service_id, :cross_site_allowed, :service_address_id)
  end

  def set_scheduling
    @schedule = Scheduling.find(params[:id])
  end

  def do_filter(schedules)
    schedules = schedules.by_staff_ids(string_to_array(params[:staff_ids])) if params[:staff_ids].present?
    schedules = schedules.by_client_ids(string_to_array(params[:client_ids])) if params[:client_ids].present?
    schedules = schedules.by_service_ids(string_to_array(params[:service_ids])) if params[:service_ids].present?
    if params[:staff_ids].blank? && params[:client_ids].blank? && params[:service_ids].blank?
      if current_user.role_name=='bcba'
        schedules = schedules.joins(client_enrollment_service: {client_enrollment: :client}).where('users.bcba_id': current_user.id).or(schedules.where(staff_id: current_user.id))
      elsif current_user.role_name=='rbt'
        schedules = schedules.where(staff_id: current_user.id)
      end
    else
      if params[:default_location_id].present?
        location_id = params[:default_location_id]
        schedules = schedules.left_outer_joins(client_enrollment_service: {client_enrollment: :client}).by_client_clinic(location_id)
                             .or(schedules.by_staff_clinic(location_id)).left_outer_joins(staff: :staff_clinics)
      end
    end
    schedules
  end

  def set_client_enrollment_service
    @client_enrollment_service = ClientEnrollmentService.find(params[:client_enrollment_service_id])
  end

  def update_client_enrollment_service
    @schedule.client_enrollment_service = ClientEnrollmentService.find(params[:client_enrollment_service_id])
    @schedule.save
  end

  def update_render_service
    if params[:is_rendered].to_bool.true?
      if schedule.date<Time.now.to_date
        schedule.unrendered_reason = ''
        if schedule.soap_notes.any?
          soap_notes.each do |soap_note|
            if soap_note.bcba_signature==false 
              schedule.unrendered_reason += ' bcba_signature_absent'
              schedule.save(validate: false)
            end
            if soap_note.clinical_director_signature==false 
              schedule.unrendered_reason += ' clinical_director_signature_absent'
              schedule.save(validate: false)
            end
            if soap_note.rbt_signature==false 
              schedule.unrendered_reason += ' rbt_signature_absent'
              schedule.save(validate: false)
            end
            if !soap_note.signature_file.attached?
              schedule.unrendered_reason += ' caregiver_signature_absent'
              schedule.save(validate: false)
            end
            if schedule.unrendered_reason.blank?
              schedule.is_rendered = true
              schedule.unrendered_reason = ''
              schedule.save(validate: false)
              break
            end
          end
        else
          schedule.unrendered_reason = 'soap_note_absent'
          schedule.save(validate: false)
        end
      end
    end
  end
  # end of private
end
