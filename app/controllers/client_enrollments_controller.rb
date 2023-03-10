class ClientEnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: :payor_statuses
  before_action :set_client, except: :payor_statuses
  before_action :set_client_enrollment, only: %i[show update destroy]

  def index
    @client_enrollments = @client&.client_enrollments&.order(is_primary: :desc)
    @client_enrollments = @client_enrollments&.paginate(page: params[:page]) if params[:page].present?
  end

  def create
    return incomplete_params unless validate_input_field_insurance

    ActiveRecord::Base.transaction do
      @client_enrollment = @client&.client_enrollments&.new(enrollment_params)
      # NOTE : reset_primary must be called after initialize, we are overriding is_primary value.
      reset_primary

      @client_enrollment&.save
    end
  end

  def show
    @client_enrollment
  end

  def update
    ActiveRecord::Base.transaction do
      reset_primary
      @client_enrollment&.update(enrollment_params)
    end
  end

  def destroy
    @client_enrollment&.destroy
  end

  def payor_statuses
    @payor_statuses = ClientEnrollment.translate_payor_statuses
  end

  private

  def authorize_user
    authorize ClientEnrollment if current_user.role_name!='super_admin'
  end

  def enrollment_params
    params.permit(:client_id, :funding_source_id, :is_primary, :insurance_id, :group, :group_employer, 
                  :subscriber_name, :subscriber_phone, :subscriber_dob, :provider_phone, 
                  :relationship, :source_of_payment, :payor_status, :enrollment_date, :terminated_on, :notes)
  end

  def set_client
    @client = Client.find(params[:client_id]) rescue nil
  end

  def set_client_enrollment
    @client_enrollment = @client.client_enrollments.find(params[:id]) rescue nil
  end

  def reset_primary
    if is_any_other_primary?
      other_primary_objects&.update_all(is_primary: false) if params[:is_primary].to_bool.true?
    else
      @client_enrollment&.is_primary = true
    end
  end

  def is_any_other_primary?
    return true if other_primary_objects.any?

    false
  end

  def other_primary_objects
    @client&.client_enrollments&.except_ids(@client_enrollment.id).where(is_primary: true)
  end

  def validate_input_field_insurance
    validation_targets = [enrollment_params[:funding_source_id], enrollment_params[:group],
                          enrollment_params[:group_employer], enrollment_params[:insurance_id]]

    if enrollment_params[:source_of_payment].eql?('insurance')
      return false if validation_targets.any?{ |element| element.nil? || element.to_s.empty? || element.to_s.eql?('NaN')}
    end

    true
  end
  # end of private
end
