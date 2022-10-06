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
  let!(:setting) { create(:setting, roles_ids: Role.ids) }

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
      let!(:setting) { create(:setting, roles_ids: []) }
      it "should update setting successfully" do
        set_auth_headers(auth_headers)

        put :update, params: { welcome_note: "welcome note", roles_ids: Role.last(1).pluck(:id)}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['welcome_note']).to eq('welcome note')
        expect(response_body['data']['roles_ids']).to eq(Role.last(1).pluck(:id))
      end
    end
  end
end
