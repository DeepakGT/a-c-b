require 'rails_helper'
require "support/render_views"

RSpec.describe StaffCredentialsController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "GET #index" do
    let!(:clinic) { create(:clinic, name: 'clinic1') }
    let!(:user) { create(:user, :with_role, role_name: 'rbt', clinic_id: clinic.id) }
    let!(:auth_headers) { user.create_new_auth_token }
    before do
      10.times { create(:staff_credential, staff_id: user.id) }
    end
    context "when sign in" do
      it "should fetch credential list successfully" do
        set_auth_headers(auth_headers)
        get :index, params: {staff_id: user.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(10)
      end
    end
  end

  describe "POST #create" do
    let!(:clinic) { create(:clinic, name: 'clinic1') }
    let!(:user) { create(:user, :with_role, role_name: 'rbt', clinic_id: clinic.id) }
    let!(:auth_headers) { user.create_new_auth_token }
    let!(:credential) { create(:credential) }
    context "when sign in" do
      it "should fetch credential list successfully" do
        set_auth_headers(auth_headers)
        post :create, params: {staff_id: user.id, credential_id: credential.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(user.reload.staff_credentials.first.id)
      end
    end
  end
end
