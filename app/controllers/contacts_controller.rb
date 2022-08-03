class ContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_client
  before_action :set_contact, only: %i[show update destroy]

  def index
    @contacts = @client&.contacts&.order(:first_name)
    @contacts = @contacts&.paginate(page: params[:page]) if params[:page].present?
  end

  def create
    @contact = @client&.contacts&.create(contact_params)
  end

  def show
    @contact
  end

  def update
    @contact&.update(contact_params)
  end

  def destroy
    @contact&.destroy
  end

  private

  def set_client
    @client = Client.find(params[:client_id]) rescue nil
  end

  def set_contact
    @contact = @client.contacts.find(params[:id]) rescue nil
  end

  def contact_params
    params.permit(:first_name, :last_name, :email, :client_id, :relation_type, :relation, :legal_guardian, 
                  :guarantor, :parent_portal_access, :resides_with_client, :is_address_same_as_client, address_attributes: 
                  %i[line1 line2 line3 zipcode city state country addressable_type addressable_id], 
                  phone_numbers_attributes: %i[id phone_type number])
  end

  def authorize_user
    authorize Contact if current_user.role_name!='super_admin'
  end
  # end of private
end
