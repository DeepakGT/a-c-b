class ContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, except: %i[relations relation_types]
  before_action :set_contact, only: %i[show update destroy]

  def index
    @contacts = @client.contacts.order(:first_name).paginate(page: params[:page])
  end

  def create
    @contact = @client.contacts.create(contact_params)
  end

  def show; end

  def update
    @contact.update(contact_params)
  end

  def destroy
    @contact.destroy
  end

  def relation_types
    @relation_types = Contact.relation_types
  end

  def relations
    @relations = Contact.relations
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_contact
    @contact = @client.contacts.find(params[:id])
  end

  def contact_params
    params.permit(:first_name, :last_name, :email, :client_id, :relation_type, :relation, :legal_guardian, 
                  :guarantor, :parent_portal_access, :resides_with_client, address_attributes: 
                  %i[line1 line2 line3 zipcode city state country addressable_type addressable_id], 
                  phone_numbers_attributes: %i[id phone_type number])
  end
end
