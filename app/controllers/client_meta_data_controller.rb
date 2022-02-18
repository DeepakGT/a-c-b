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
    staff = @client.clinic.staff.joins(:role).where('role.name': ['bcba', 'rbt'])
    selectable_options = { services: Service.all,
                           client_enrollments: client_enrollments,
                           service_providers: staff }
  end
  # end of private
end
