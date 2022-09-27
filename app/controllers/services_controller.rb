class ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_service, only: %i[update show destroy]

  def index
    @services = Service.order(:name)
    @services = @services&.paginate(page: params[:page]) if params[:page].present?
  end

  def create
    @service = Service.new(service_params)
    @service&.id = Service.ids.max+1
    @service&.save
  end

  def show
    @service
  end

  def update
    Service.transaction do
      remove_qualifications if params[:service_qualifications_attributes].present?
      @service&.update(service_params)
    end
  end

  def destroy
    @service&.destroy
  end

  private

  def service_params
    params.permit(:name, :status, :display_code, :is_service_provider_required, :is_unassigned_appointment_allowed, 
                  :selected_non_early_service_id, :max_units,:is_early_code, :allow_soap_notes_from_connect,
                  service_qualifications_attributes: :qualification_id).merge({selected_payors: params[:selected_payors]&.to_json})
  end

  def set_service
    @service = Service.find(params[:id]) rescue nil
  end

  def authorize_user
    authorize Service if current_user.role_name!='super_admin'
  end

  def remove_qualifications
    @service&.qualifications&.destroy_all
  end
  # end of private
end
