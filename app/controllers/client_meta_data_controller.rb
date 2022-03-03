class ClientMetaDataController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client

  def selectable_options
    @selectable_options = get_selectable_options_data
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def get_selectable_options_data
    client_enrollments = @client.client_enrollments.active.where.not(source_of_payment: 'self_pay')
    staff = @client.clinic.staff_clinics
    selectable_options = { services: Service.order(:name),
                           client_enrollments: client_enrollments&.order(is_primary: :desc),
                           service_providers: staff&.order(is_home_clinic: :desc) }
  end
  # end of private
end
