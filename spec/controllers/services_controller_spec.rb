require 'rails_helper'
require "support/render_views"

RSpec.describe ServicesController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "GET #index" do
    let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
    let!(:auth_headers) { user.create_new_auth_token }
    before do
      create(:service, name: 'service1')
      create(:service, name: 'service2')
    end
    context "when sign in" do
      it "should fetch services list successfully" do
        request.headers['Uid'] = auth_headers['uid']
        request.headers['Access-Token'] = auth_headers['access-token']
        request.headers['Client'] = auth_headers['client']
        
        get :index
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(2)
      end
    end
  end

  describe "POST #create" do
    let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
    let!(:auth_headers) { user.create_new_auth_token }

    context "when sign in" do
      let!(:service_name) {'test-service-1'}
      it "should create service successfully" do
        request.headers['Uid'] = auth_headers['uid']
        request.headers['Access-Token'] = auth_headers['access-token']
        request.headers['Client'] = auth_headers['client']
        
        post :create, params: {name: service_name}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['name']).to eq(service_name)
      end
    end
  end
end
