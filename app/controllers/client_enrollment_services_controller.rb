FORMAT_DATE = '%Y-%m-%d'.freeze

class ClientEnrollmentServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: :create_early_auths
  before_action :set_client_enrollment_service, only: %i[show update destroy]

  def create
    set_client_enrollment
    @enrollment_service = @client_enrollment.client_enrollment_services.create(enrollment_service_params)
    update_staff_legacy_numbers
    #update_units_columns(@enrollment_service)
  end

  def show
    @enrollment_service  
  end

  def update
    ClientEnrollmentService.transaction do
      remove_service_providers if params[:service_providers_attributes].present?
      @enrollment_service.update(enrollment_service_params)
      update_client_enrollment if params[:funding_source_id].present?
      update_staff_legacy_numbers
    end
  end

  def destroy
    @enrollment_service.destroy
  end

  def create_early_auths
    @client = Client.find(early_auth_params[:client_id]) rescue nil
    authorize @client if current_user.role_name!='super_admin'
    authorizations = ClientEnrollmentService.by_client(@client.id).joins(:service).where('services.is_early_code': true).where('client_enrollments.funding_source_id': early_auth_params[:funding_source_id])
    if authorizations.present?
      @client.errors.add(:early_authorization, 'is already present for this non-billable funding source.')
    else
      end_date = (Time.current+90.days).strftime(FORMAT_DATE)
      @client_enrollment = @client.client_enrollments.create(funding_source_id: early_auth_params[:funding_source_id], enrollment_date: Time.current.strftime(FORMAT_DATE), terminated_on: end_date, source_of_payment: 'insurance')
      services = Service.all.map{|service| service if JSON.parse(service&.selected_payors)&.pluck('payor_id')&.include?("#{early_auth_params[:funding_source_id]}")}.compact

      services.each do |service|
        @client_enrollment.client_enrollment_services.create(service_id: service.id, start_date: Time.current.strftime(FORMAT_DATE), end_date: end_date, units: service.max_units, minutes: (service.max_units)*15)
      end
    end
  end

  private

  def authorize_user
    authorize ClientEnrollmentService if current_user.role_name != 'super_admin'
  end

  def set_client_enrollment
    client = Client.find(params[:client_id])
    if params[:funding_source_id].present?
      @client_enrollment = client.client_enrollments.find_by(funding_source_id: params[:funding_source_id])
    else
      @client_enrollment = client.client_enrollments.find_by(source_of_payment: 'self_pay')
    end
  end

  def set_client_enrollment_service
    @enrollment_service = ClientEnrollmentService.find(params[:id])
  end

  def update_client_enrollment
    set_client_enrollment 
    @enrollment_service.client_enrollment = @client_enrollment
    @enrollment_service.save
  end

  def enrollment_service_params
    params.permit(:service_id, :start_date, :end_date, :units, :minutes, :service_number,
                  service_providers_attributes: %i[id staff_id])
  end

  def remove_service_providers
    @enrollment_service.service_providers.destroy_all
  end

  def update_units_columns(client_enrollment_service)
    # ClientEnrollmentServices::UpdateUnitsColumnsOperation.call(client_enrollment_service)
  end

  def update_staff_legacy_numbers
    return if params[:legacy_numbers].blank?
  
    params[:legacy_numbers].each do |item|
      Staff.find_by(id: item[:staff_id])&.update(legacy_number: item[:legacy_number])
    end
  end
  
  def early_auth_params
    params.permit(:client_id, :funding_source_id)
  end
  # end of private
end
