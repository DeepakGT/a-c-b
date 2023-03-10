class ClientMetaDataController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_service, only: %i[service_providers_list funding_sources_list]

  def selectable_options
    @selectable_options = selectable_options_data
  end

  def service_providers_list
    staff = @client&.clinic&.staff
    staff = check_qualification(staff)
    @staff = staff&.uniq&.sort_by(&:id)
  end

  def client_data
    @schedules = Scheduling.includes(client_enrollment_service: :client_enrollment).by_client_ids(@client&.id).scheduled_scheduling.order(:date)&.first(10)
    if params[:show_expired_before_30_days].to_bool.true?
      @client_enrollment_services = ClientEnrollmentService.by_client(@client&.id)&.first(10)
    else
      @client_enrollment_services = ClientEnrollmentService.by_client(@client&.id).not_expired_before_30_days&.first(10)
    end
    @soap_notes = SoapNote.by_client(@client&.id).order(add_date: :desc, created_at: :desc).first(10)
    @notes = ClientNote.by_client_id(@client&.id)&.first(10)
    @attachments = Attachment.by_client_id(@client&.id)&.first(10)
  end

  def soap_notes
    @soap_notes = SoapNote.by_client(@client&.id).order(add_date: :desc, created_at: :desc)
    @soap_notes = @soap_notes&.paginate(page: params[:page], per_page: params[:per_page] || 30) if params[:page].present?
  end

  def soap_note_detail
    @soap_note = SoapNote.by_client(@client&.id).find(params[:id])
  end

  def funding_sources_list
    if @service&.is_early_code?
      @client_enrollments = @client&.client_enrollments&.active&.joins(:funding_source).non_billable_funding_sources
    else
      @client_enrollments = @client&.client_enrollments&.active.joins(:funding_source).billable_funding_sources
    end
  end

  private

  def set_client
    @client = Client.find(params[:client_id]) rescue nil
  end

  def set_service
    @service = Service.find(params[:service_id]) rescue nil
  end

  def selectable_options_data
    if params[:early_authorization_id].present?
      early_authorization = ClientEnrollmentService.find(params[:early_authorization_id]) rescue nil
      return {services: Service.where(id: early_authorization&.service&.selected_non_early_service_id)}
    end
    { services: Service.order(:name) }
  end

  def check_qualification(staff)
    service_qualification_ids = @service&.service_qualifications&.pluck(:qualification_id)
    return staff if service_qualification_ids.empty?
    
    staff = staff.by_service_qualifications(service_qualification_ids)
  end
  # end of private
end
