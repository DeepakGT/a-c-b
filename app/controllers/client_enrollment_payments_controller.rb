class ClientEnrollmentPaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_client
  before_action :set_enrollment_payment, only: %i[show update destroy]

  def index
    @client_enrollment_payments = @client.enrollment_payments.order(:subscriber_name)
  end

  def show; end

  def create
    @client_enrollment_payment = @client.enrollment_payments.create(enrollment_payment_params)
  end

  def update
    @client_enrollment_payment.update(enrollment_payment_params)
  end

  def destroy
    @client_enrollment_payment.destroy
  end

  private

  def authorize_user
    authorize ClientEnrollmentPayment if current_user.role_name!='super_admin'
  end

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_enrollment_payment
    @client_enrollment_payment = @client.enrollment_payments.find(params[:id])
  end

  def enrollment_payment_params
    params.permit(:funding_source_id, :insurance_id, :group, :group_employer, :provider_phone, 
                  :subscriber_name, :subscriber_phone, :subscriber_dob, :source_of_payment, :relationship)
  end
  # end of private

end
