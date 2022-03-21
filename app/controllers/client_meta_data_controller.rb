class ClientMetaDataController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_service, only: :service_providers_list

  def selectable_options
    @selectable_options = get_selectable_options_data
  end

  def service_providers_list
    staff = @client.clinic.staff
    staff = check_qualification(staff)
    @staff = staff&.uniq.sort_by(&:id)
  end

  def client_data
    @schedules = Scheduling.by_client_ids(@client.id).scheduled_scheduling.order(:date).first(10)
    @client_enrollment_services = ClientEnrollmentService.by_client(@client.id).first(10)
    # @client_enrollment_services = ClientEnrollmentService.where(id: @schedules.pluck(:client_enrollment_service_id).uniq).first(10)
    @soap_notes = SoapNote.by_client(@client.id).order(add_date: :desc, created_at: :desc).first(10)
    @notes = ClientNote.where(client_id: @client.id).first(10)
    @attachments = Attachment.where(attachable_type: 'User', attachable_id: @client.id).first(10)
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_service
    @service = Service.find(params[:service_id])
  end

  def get_selectable_options_data
    client_enrollments = @client.client_enrollments.active.where.not(source_of_payment: 'self_pay')
    selectable_options = { services: Service.order(:name),
                           client_enrollments: client_enrollments&.order(is_primary: :desc) }
  end

  def check_qualification(staff)
    service_qualification_ids = @service.service_qualifications.pluck(:qualification_id)
    return staff if service_qualification_ids.empty?
    
    # staff = staff.map{|s| s if service_qualification_ids.difference(s.staff_qualifications.pluck(:credential_id)).empty? }
    # staff.delete(nil)
    staff = staff.joins(:staff_qualifications).where('staff_qualifications.credential_id': service_qualification_ids)
    # staff
  end
  # end of private
end
