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

        get :index, params: {clinic_id: clinic.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(clients.count)
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
          password_confirmation: '123456',
          contacts_attributes: [{
            first_name: 'test', 
            last_name: 'contact', 
            address_attributes: { city: 'Indore'},
            phone_number_attributes: { number: '9988776655'}
          }]
        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['first_name']).to eq('test')
        expect(response_body['data']['contacts'][0]['last_name']).to eq('contact')
        expect(response_body['data']['contacts'][0]['address']['city']).to eq('Indore')
        expect(response_body['data']['contacts'][0]['phone_number']['number']).to eq('9988776655')
      end
    end
  end
end
