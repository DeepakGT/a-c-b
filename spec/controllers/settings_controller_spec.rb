require 'rails_helper'
require "support/render_views"

RSpec.describe SettingsController, type: :controller do
	before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  let!(:user) { create(:user, :with_role, role_name: 'super_admin') }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:setting) { create(:setting) }

  describe "GET #show" do
    context "when sign in" do
      it "should show setting successfully" do
        set_auth_headers(auth_headers)

        get :show
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['welcome_note']).to eq('welcome!')
      end
    end
  end

  describe "PUT #update" do
    context "when sign in" do
      it "should update setting successfully" do
        set_auth_headers(auth_headers)

        put :update, params: { welcome_note: "welcome note"}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['welcome_note']).to eq('welcome note')
      end
    end
  end
end
