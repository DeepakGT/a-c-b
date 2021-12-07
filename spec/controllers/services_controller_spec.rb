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
    let!(:organization) {create(:organization, name: 'org1', admin_id: user.id)}
    before do
      create(:service, name: 'service1')
      create(:service, name: 'service2')
    end
    context "when sign in" do
      it "should fetch client list successfully" do
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
end
