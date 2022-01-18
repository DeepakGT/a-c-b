class ClientEnrollmentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @client_enrollment = ClientEnrollment.create(enrollment_params)
  end

  private

  def enrollment_params
    params.permit(:client_id, :funding_source_id, :enrollment_date, :terminated_at, 
                  :insureds_name, :notes, :top_invoice_note, :bottom_invoice_note)
  end
end
