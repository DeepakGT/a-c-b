FORMAT_DATE = '%Y-%m-%d'.freeze

class ClientEnrollmentServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: :create_early_auths
  before_action :set_client_enrollment_service, only: %i[show update destroy]

  def create
    set_client_enrollment
    @enrollment_service = @client_enrollment&.client_enrollment_services&.create(enrollment_service_params)
    update_staff_legacy_numbers
    replace_early_auth if params[:early_authorization_id].present? && !@enrollment_service&.id.nil?
  end

  def show
    @enrollment_service  
  end

  def update
    ClientEnrollmentService.transaction do
      remove_service_providers if params[:service_providers_attributes].present?
      @enrollment_service&.update(enrollment_service_params)
      update_client_enrollment if params[:funding_source_id].present?
      update_staff_legacy_numbers
    end
  end

  def destroy
    @enrollment_service&.destroy
  end

  def create_early_auths
    @client = Client.find(early_auth_params[:client_id]) rescue nil
    authorize @client, policy_class: ClientEnrollmentServicePolicy if current_user.role_name!='super_admin'
    authorizations = ClientEnrollmentService.by_client(@client&.id).joins(:service).where('services.is_early_code': true).where('client_enrollments.funding_source_id': early_auth_params[:funding_source_id])
    if authorizations.present?
      @client.errors.add(:early_authorization, 'is already present for this non-billable funding source.')
    else
      end_date = (Time.current+90.days).strftime(FORMAT_DATE)
      @client_enrollment = @client&.client_enrollments&.create(funding_source_id: early_auth_params[:funding_source_id], enrollment_date: Time.current.strftime(FORMAT_DATE), terminated_on: end_date, source_of_payment: 'insurance')
      services = Service.all.select{|service| service if !service.selected_payors.nil? }
      services = services.map{|service| service if service&.is_early_code.true? && JSON.parse(service&.selected_payors)&.pluck('payor_id').map(&:to_i)&.include?(early_auth_params[:funding_source_id]&.to_i)}.compact

      if services.present?
        services.each do |service|
          client_enrollment_service = @client_enrollment.client_enrollment_services.new(service_id: service.id, start_date: Time.current.strftime(FORMAT_DATE), end_date: end_date, units: service.max_units, minutes: (service.max_units)*15)
          client_enrollment_service.minutes = (service.max_units)*15 if service&.max_units.present?
          client_enrollment_service.save
        end
        delete_client_enrollment if @client_enrollment&.client_enrollment_services.blank?
      else 
        delete_client_enrollment if @client_enrollment&.client_enrollment_services.blank?
        @client&.errors&.add(:funding_source, 'is not present in selected payors list of any service.')
      end
    end
  end

  private

  def authorize_user
    authorize ClientEnrollmentService if current_user.role_name != 'super_admin'
  end

  def set_client_enrollment
    client = Client.find(params[:client_id])  rescue nil
    if params[:funding_source_id].present?
      @client_enrollment = client&.client_enrollments&.find_by(funding_source_id: params[:funding_source_id])
    else
      @client_enrollment = client&.client_enrollments&.find_by(source_of_payment: 'self_pay')
    end
  end

  def set_client_enrollment_service
    @enrollment_service = ClientEnrollmentService.find(params[:id]) rescue nil
  end

  def update_client_enrollment
    set_client_enrollment 
    @enrollment_service&.client_enrollment = @client_enrollment
    @enrollment_service&.save
  end

  def enrollment_service_params
    params.permit(:service_id, :start_date, :end_date, :units, :minutes, :service_number, 
                  service_providers_attributes: %i[id staff_id])
  end

  def remove_service_providers
    @enrollment_service&.service_providers&.destroy_all
  end

  def check_rendering_provider_condition(schedule)
    return true if (!@final_authorization&.service&.is_service_provider_required? || schedule&.staff&.role_name!='bcba')

    bcba_ids = @final_authorization&.service_providers&.pluck(:staff_id)
    return true if bcba_ids&.include?(schedule&.staff_id)

    false
  end

  def update_staff_legacy_numbers
    return if params[:legacy_numbers].blank? || @enrollment_service&.id.nil?
  
    params[:legacy_numbers].each do |item|
      Staff.find_by(id: item[:staff_id])&.update(legacy_number: item[:legacy_number])
    end
  end

  def early_auth_params
    params.permit(:client_id, :funding_source_id)
  end

  def delete_client_enrollment
    @client_enrollment&.destroy
    @client_enrollment = nil
  end
  
  def delete_early_authorization
    @early_authorization&.destroy
    @early_authorization = nil
  end

  def replace_early_auth
    authorize :client_enrollment_service, :replace_early_auth? if current_user.role_name!='super_admin'
    
    @early_authorization = ClientEnrollmentService.find(params[:early_authorization_id]) rescue nil
    if !@enrollment_service.id.nil? && @early_authorization.present?
      schedules = @early_authorization&.schedulings&.within_dates(@enrollment_service&.start_date, @enrollment_service&.end_date)
      schedules&.each do |schedule|
        schedule&.update(client_enrollment_service_id: @enrollment_service&.id) if (check_rendering_provider_condition(schedule) && @enrollment_service&.left_units>=schedule&.units)
      end
      delete_early_authorization if @early_authorization&.schedulings&.blank?
      RenderAppointments::RenderPartiallyRenderedSchedulesOperation.call(@enrollment_service&.id)
    else
      @early_authorization&.errors&.add(:final_authorization, 'does not exist for selected early authorization.')
    end
  end
  # end of private
end
