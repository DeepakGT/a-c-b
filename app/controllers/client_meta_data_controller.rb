class ClientMetaDataController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_service, only: :service_providers_list

  def selectable_options
    @selectable_options = selectable_options_data
  end

  def service_providers_list
    staff = @client.clinic.staff
    staff = check_qualification(staff)
    @staff = staff&.uniq&.sort_by(&:id)
  end

  def client_data
    @schedules = Scheduling.includes(client_enrollment_service: :client_enrollment).by_client_ids(@client.id).scheduled_scheduling.order(:date).first(10)
    if params[:show_expired_before_30_days].to_bool.true?
      @client_enrollment_services = ClientEnrollmentService.by_client(@client.id).first(10)
    else
      @client_enrollment_services = ClientEnrollmentService.by_client(@client.id).not_expired_before_30_days.first(10)
    end
    @soap_notes = SoapNote.by_client(@client.id).order(add_date: :desc, created_at: :desc).first(10)
    @notes = ClientNote.by_client_id(@client.id).first(10)
    @attachments = Attachment.by_client_id(@client.id).first(10)
  end

  def soap_notes
    @soap_notes = SoapNote.by_client(params[:client_id]).order(add_date: :desc, created_at: :desc)
                          .paginate(page: params[:page] || 1, per_page: params[:per_page] || 30)
  end

  def soap_note_detail
    @soap_note = SoapNote.by_client(params[:client_id]).find(params[:id])
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_service
    @service = Service.find(params[:service_id])
  end

  def selectable_options_data
    client_enrollments = @client.client_enrollments.active.where.not(source_of_payment: 'self_pay')
    selectable_options = { services: Service.order(:name),
                           client_enrollments: client_enrollments&.order(is_primary: :desc) }
  end

  def check_qualification(staff)
    service_qualification_ids = @service.service_qualifications.pluck(:qualification_id)
    return staff if service_qualification_ids.empty?
    
    # staff = staff.map{|s| s if service_qualification_ids.difference(s.staff_qualifications.pluck(:credential_id)).empty? }
    # staff.delete(nil)
    staff = staff.by_service_qualifications(service_qualification_ids)
    # staff
  end
  # end of private
end
