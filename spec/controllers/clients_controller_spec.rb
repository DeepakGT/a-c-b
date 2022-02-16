require 'rails_helper'
require "support/render_views"

RSpec.describe ClientsController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:role) { create(:role, name: 'aba_admin', permissions: ['clients_view', 'clients_update'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'org1', admin_id: user.id)}
  let!(:clinic) {create(:clinic, name: 'clinic1', organization_id: organization.id)}

  describe "GET #index" do
    context "when sign in" do
      let!(:clients) { create_list(:client, 4, clinic_id: clinic.id)}
      it "should list client successfully" do
        set_auth_headers(auth_headers)
        
        get :index, :format => :json
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(clients.count)
      end

      it "should fetch the first page record by default" do
        set_auth_headers(auth_headers)
        
        get :index
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq(1)
      end

      it "should fetch the given page record" do
        set_auth_headers(auth_headers)
        
        get :index, params: { page: 2}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq("2")
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      let(:client) { create(:client, clinic_id: clinic.id)}
      it "should show client detail successfully" do
        set_auth_headers(auth_headers)

        get :show, params: {id: client.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client.id)
      end
    end
  end

  describe "POST #create" do
    context "when sign in" do
      it "should create a client successfully" do
        set_auth_headers(auth_headers)

        post :create, params: { 
          clinic_id: clinic.id,
          first_name: 'test',
          last_name: 'client',
          email: 'testcontact@gamil.com',
          payor_status: 'insurance',
          addresses_attributes: [{address_type: 'insurance_address', city: 'Indore'}, 
                                 {address_type: 'service_address', city: 'Delhi'}],
          phone_number_attributes: {phone_type: 'home', number: '99999 99999'}
        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['first_name']).to eq('test')
        expect(response_body['data']['addresses'].count).to eq(2)
        expect(response_body['data']['addresses'].first['type']).to eq('insurance_address')
        expect(response_body['data']['phone_number']['phone_type']).to eq('home')
      end
    end
  end

  describe "PUT #update" do
    context "when sign in" do
      let(:client) { 
        create(:client, clinic_id: clinic.id, first_name: 'test', 
               phone_number_attributes: {phone_type: 'home'}, 
               addresses_attributes: [{address_type: 'insurance_address', city: 'Indore'}])
      }
      let(:updated_first_name) {'test-client-1'}
      it "should update a client successfully" do
        set_auth_headers(auth_headers)

        put :update, params: { id: client.id, first_name: updated_first_name }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client.id)
        expect(response_body['data']['first_name']).to eq(updated_first_name)
      end

      context "and update associated data" do
        let(:clinic) {create(:clinic, name: 'clinic', organization_id: organization.id)}
        it "should update associated clinic" do
          set_auth_headers(auth_headers)

          put :update, params: { id: client.id, clinic_id: clinic.id }
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(client.id)
        end

        let(:updated_phone_type) {'mobile'}
        it "should update associated phone number" do
          set_auth_headers(auth_headers)

          put :update, params: { id: client.id, phone_number_attributes: {phone_type: updated_phone_type} }
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(client.id)
          expect(response_body['data']['phone_number']['phone_type']).to eq(updated_phone_type)
        end

        let(:updated_address_type) {'service_address'}
        it "should update associated address" do
          set_auth_headers(auth_headers)

          put :update, params: { id: client.id, addresses_attributes: [{id: client.addresses.first.id, address_type: updated_address_type}] }
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(client.id)
          expect(response_body['data']['addresses'].first['type']).to eq(updated_address_type)
        end
      end
    end
  end
end
