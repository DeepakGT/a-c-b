class ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_service, only: %i[update show]

  def index
    @services = Service.order(:name).paginate(page: params[:page])
  end

  def create
    @service = Service.create(service_params)
  end

  def show; end

  def update
    Service.transaction do
      remove_qualifications if params[:service_qualifications_attributes].present?
      @service.update(service_params)
    end
  end

  private

  def service_params
    params.permit(:name, :status, :display_code, service_qualifications_attributes: :qualification_id)
  end

  def set_service
    @service = Service.find(params[:id])
  end

  def authorize_user
    authorize Service if current_user.role_name!='super_admin'
  end

  def remove_qualifications
    @service.qualifications.destroy_all
  end
  # end of private

end
