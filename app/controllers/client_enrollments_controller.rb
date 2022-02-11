class ClientEnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_client_enrollment, only: %i[show update destroy]

  def index
    @client_enrollments = @client.client_enrollments.order(is_primary: :desc).paginate(page: params[:page])
  end

  def create
    @client_enrollment = @client.client_enrollments.create(enrollment_params)
  end

  def show; end

  def update
    @client_enrollment.update(enrollment_params)
  end

  def destroy
    @client_enrollment.destroy
  end

  private

  def enrollment_params
    params.permit(:client_id, :funding_source_id, :enrollment_date, :terminated_on, :is_primary,
                  :insureds_name, :notes, :top_invoice_note, :bottom_invoice_note)
  end

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_client_enrollment
    @client_enrollment = @client.client_enrollments.find(params[:id])
  end
  # end of private
  
end
