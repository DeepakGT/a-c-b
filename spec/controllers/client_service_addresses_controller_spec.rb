require 'rails_helper'
require 'support/render_views'

RSpec.describe ClientServiceAddressesController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  let!(:role) { create(:role, name: 'executive_director', permissions: ['client_service_address_view', 'client_service_address_update', 'client_service_address_delete'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'test-organization', admin_id: user.id)}
  let!(:clinic) {create(:clinic, name: 'test-clinic', organization_id: organization.id, address_attributes: {city: 'Bangalore'})}
  let!(:client) { create(:client, clinic_id: clinic.id)}
  let!(:service_address_type) {create_list(:service_address_type, 5)}
  
  describe "GET #index" do
    context "when sign in" do
      let!(:client_service_addresses) { create_list(:address, 5, addressable_type: 'Client', addressable_id: client.id, is_default: false, address_type: 'service_address', service_address_type_id: service_address_type[rand(5)].id) }
      let!(:client_service_address) { create(:address, addressable_type: 'Client', addressable_id: client.id, is_default: true, address_type: 'service_address', service_address_type_id: service_address_type[rand(5)].id) }
      it "should fetch client service addresses list successfully" do
        
        set_auth_headers(auth_headers)
        
        get :index, params: { client_id: client.id}
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(client_service_addresses.count + Constant.one)
      end

      context "when no service addresses for client is present in database" do
        it "should display empty list" do
          set_auth_headers(auth_headers)

          get :index, params: { client_id: client.id}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(client_service_addresses.count + Constant.one)
        end
      end

      context "when there is a service address with the current clinic address" do
        it "should return true in the response on the office_address key" do
          set_auth_headers(auth_headers)
          create(:address,
                 addressable_type: 'Client',
                 addressable_id: client.id,
                 address_type: 'service_address',
                 line1: clinic.address.line1,
                 city: clinic.address.city,
                 state: clinic.address.state,
                 country: clinic.address.country,
                 zipcode: clinic.address.zipcode,
                 service_address_type_id: service_address_type[rand(5)].id)

          get :index, params: { client_id: client.id }
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(client_service_addresses.count + Constant.two)
          expect(response_body['office_address']).to eq(true)
        end
      end
    end
  end
  
  describe "POST #create" do
    context "when sign in" do
      it "should create client service address successfully" do
        set_auth_headers(auth_headers)

        post :create, params: {
          client_id: client.id,
          city: 'Delhi',
          is_default: true,
          service_address_type_id: service_address_type[rand(5)].id
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_id']).to eq(client.id) 
        expect(response_body['data']['city']).to eq('Delhi')
        expect(response_body['data']['is_default']).to eq(true)
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      let(:client_service_address) { create(:address, addressable_type: 'Client', addressable_id: client.id, is_default: true, address_type: 'service_address', service_address_type_id: service_address_type[rand(5)].id) }
      it "should fetch client service address detail successfully" do
        set_auth_headers(auth_headers)

        get :show, params: {client_id: client.id, id: client_service_address.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_id']).to eq(client.id) 
        expect(response_body['data']['id']).to eq(client_service_address.id) 
      end
    end
  end

  describe "PUT #update" do
    context "when sign in" do
      let(:client_service_address) { create(:address, addressable_type: 'Client', addressable_id: client.id, is_default: false, address_type: 'service_address', city: 'Indore', service_address_type_id: service_address_type[rand(5)].id) }
      it "should update client service address successfully" do
        set_auth_headers(auth_headers)

        put :update, params: {id: client_service_address.id, client_id: client.id, city: 'Hyderabad', is_default: true}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_id']).to eq(client.id) 
        expect(response_body['data']['id']).to eq(client_service_address.id)
        expect(response_body['data']['city']).to eq('Hyderabad')
        expect(response_body['data']['is_default']).to eq(true)
      end

      context "and try to uncheck is_default" do
        let(:client_service_address) { create(:address, addressable_type: 'Client', addressable_id: client.id, is_default: true, address_type: 'service_address', city: 'Indore', service_address_type_id: service_address_type[rand(5)].id) }
        it "should update is_default successfully" do
          set_auth_headers(auth_headers)
  
          put :update, params: {id: client_service_address.id, client_id: client.id, is_default: false}
          response_body = JSON.parse(response.body)
  
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['client_id']).to eq(client.id) 
          expect(response_body['data']['id']).to eq(client_service_address.id)
          expect(response_body['data']['is_default']).to eq(false)
        end  
      end
    end
  end

  describe "DELETE #destroy" do
    context "when sign in" do
      let(:client_service_address) { create(:address, addressable_type: 'Client', addressable_id: client.id, is_default: false, address_type: 'service_address', city: 'Indore') }
      it "should delete client service address successfully" do
        set_auth_headers(auth_headers)
        delete :destroy, params: {client_id: client.id, id: client_service_address.id} 
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client_service_address.id)
        expect(ClientNote.find_by_id(client_service_address.id)).to eq(nil)
      end

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          delete :destroy, params: { client_id: 0, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "when id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          delete :destroy, params: { client_id: client.id, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end
    end
  end

  describe "POST #create_office_address" do
    context "when sign in" do
      it "should create office address for client successfully" do
        set_auth_headers(auth_headers)

        post :create_office_address, params: {client_id: client.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_id']).to eq(client.id) 
        expect(response_body['data']['type']).to eq('service_address')
        expect(response_body['data']['city']).to eq(clinic.address.city)
        expect(response_body['data']['service_address_type_id'].present?).to eq(true)
      end
    end
  end
end
