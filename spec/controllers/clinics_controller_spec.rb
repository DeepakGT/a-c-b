require 'rails_helper'
require "support/render_views"

RSpec.describe ClinicsController, type: :controller do
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
    
    context "when sign in" do
      let!(:clinics) { create_list(:clinic, 3)}
      it "should fetch client list successfully" do
        set_auth_headers(auth_headers)
        
        get :index, params: {page: 1}, :format => :json
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(clinics.count)
      end
    end
  end
end
