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
    before do
      create(:clinic, name: 'clinic1', organization_id: organization.id)
      create(:clinic, name: 'clinic2', organization_id: organization.id)
    end
    context "when sign in" do
      it "should fetch client list successfully" do
        set_auth_headers(auth_headers)
        
        get :index, params: {organization_id: 1, page: 1}, :format => :json
        response_body = JSON.parse(response.body)

        expect(assigns(:clinics).ids.sort).to eq(assigns(:organization).clinics.ids.sort)
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
      end
    end
  end
end
