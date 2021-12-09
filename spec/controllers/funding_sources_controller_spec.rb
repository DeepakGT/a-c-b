require 'rails_helper'
require "support/render_views"

RSpec.describe FundingSourcesController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "POST #create" do
    let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
    let!(:auth_headers) { user.create_new_auth_token }
    let!(:organization) {create(:organization, name: 'org1', admin_id: user.id)}
    let!(:clinic) {create(:clinic, name: 'clinic1', organization_id: organization.id)}
    context "when sign in" do
      it "should create funding source successfully" do
        set_auth_headers(auth_headers)
        
        post :create, params: {clinic_id: clinic.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['clinic_id']).to eq(clinic.id)
      end
    end
  end
end
