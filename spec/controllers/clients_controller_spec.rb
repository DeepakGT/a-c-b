require 'rails_helper'
require "support/render_views"

RSpec.describe ClientsController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:user) { create(:user, :with_role, role_name: 'aba_admin', first_name: 'admin', last_name: 'user') }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'org1', admin_id: user.id)}
  let!(:clinic) {create(:clinic, name: 'clinic1', organization_id: organization.id)}

  describe "GET #index" do
    context "when sign in" do
      let!(:clients) { create_list(:client, 4, :with_role, clinic_id: clinic.id)}
      it "should list client successfully" do
        set_auth_headers(auth_headers)
        
        get :index, :format => :json
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(clients.count)
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      let(:client) { create(:client, :with_role, clinic_id: clinic.id)}
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
          password: '123456',
          password_confirmation: '123456'
        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['first_name']).to eq('test')
      end
    end
  end

  describe "PUT #update" do
    context "when sign in" do
      let(:client) { create(:client, :with_role, clinic_id: clinic.id, first_name: 'test')}
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
    end
  end
end
