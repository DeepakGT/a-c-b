require 'rails_helper'
require 'support/render_views'

RSpec.describe ContactsController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end
  let!(:role) { create(:role, permissions: ['contacts_index', 'contacts_show', 'contacts_create', 
    'contacts_update', 'contacts_destroy'])}
  let!(:user) { create(:user, :with_role, role_name: role.name, first_name: 'admin', last_name: 'user') }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'test-organization', admin_id: user.id)}
  let!(:clinic) {create(:clinic, name: 'test-clinic', organization_id: organization.id)}
  let!(:client) { create(:client, clinic_id: clinic.id)}

  describe "GET #index" do
    context "when sign in" do
      let!(:contacts){ create_list(:contact, 4, client_id: client.id)}
      it "should list contacts successfully" do
        set_auth_headers(auth_headers)

        get :index, params: { client_id: client.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(contacts.count)
      end

      it "should fetch the first page record by default" do
        set_auth_headers(auth_headers)
        
        get :index, params: { client_id: client.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq(1)
      end

      it "should fetch the given page record" do
        set_auth_headers(auth_headers)
        
        get :index, params: { client_id: client.id, page: 2}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq("2")
      end
    end
  end

  describe "POST #create" do
    context "when sign in" do
      it "should create client contact successfully" do
        set_auth_headers(auth_headers)

        post :create, params: {
          client_id: client.id,
          first_name: 'Test',
          last_name: 'Contact1',
          email: 'test1@yopmail.com',
          relation_type: 'self',
          relation: 'self',
          address_attributes: {city: 'Indore'},
          phone_numbers_attributes: [{phone_type: 'work', number: '9988778899'}]
        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['first_name']).to eq('Test')
        expect(response_body['data']['last_name']).to eq('Contact1')
        expect(response_body['data']['email']).to eq('test1@yopmail.com')
        expect(response_body['data']['address']['city']).to eq('Indore')
        expect(response_body['data']['phone_numbers'].count).to eq(1)
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      let(:contact) { create(:contact, client_id: client.id)}
      it "should fetch contact detail successfully" do
        set_auth_headers(auth_headers)
        
        get :show, params: {client_id: client.id, id: contact.id}
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(contact.id)
        expect(response_body['data']['client_id']).to eq(client.id)
      end
    end
  end

  describe "PUT #update" do
    context "when sign in" do
      let(:contact) { create(:contact, client_id: client.id, address_attributes: {city: 'Indore'}, phone_numbers_attributes: [{number: '8888899999'}])}
      let(:updated_first_name) {'Dr. A'}
      it "should update contact successfully" do
        set_auth_headers(auth_headers)

        put :update, params: { client_id: client.id, id: contact.id, first_name: updated_first_name}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(contact.id)
        expect(response_body['data']['first_name']).to eq(updated_first_name)
      end

      context "and update associated data" do
        let(:updated_address_city) {'Delhi'}
        it "update address successfully" do
          set_auth_headers(auth_headers)

          put :update, params: { client_id: client.id, id: contact.id, address_attributes: {city: updated_address_city}}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(contact.id)
          expect(response_body['data']['address']['city']).to eq(updated_address_city)
        end

        let(:updated_phone_number) {'999 888 7777'}
        it "update phone number successfully" do
          set_auth_headers(auth_headers)

          put :update, params: { client_id: client.id, id: contact.id, phone_numbers_attributes: [{id: contact.phone_numbers.first.id, number: updated_phone_number}]}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(contact.id)
          expect(response_body['data']['phone_numbers'].first['number']).to eq(updated_phone_number)
        end
      end
    end
  end
  
  describe "DELETE #destroy" do
    context "when sign in" do
      let(:contact) { create(:contact, client_id: client.id)}
      it "should delete contact detail successfully" do
        set_auth_headers(auth_headers)
        
        delete :destroy, params: {client_id: client.id, id: contact.id}
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(contact.id)
        expect(Contact.find_by_id(contact.id)).to eq(nil)
      end
    end
  end
end
