class ClientEnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_client_enrollment, only: :show

  def index
    @client_enrollments = @client.client_enrollments.order(:enrollment_date).paginate(page: params[:page])
  end

  def create
    @client_enrollment = @client.client_enrollments.create(enrollment_params)
  end

  def show; end

  private

  def enrollment_params
    params.permit(:client_id, :funding_source_id, :enrollment_date, :terminated_at, 
                  :insureds_name, :notes, :top_invoice_note, :bottom_invoice_note)
  end

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_client_enrollment
    @client_enrollment = @client.client_enrollments.find(params[:id])
  end
end
