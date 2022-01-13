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

  describe "GET #index" do
    context "when sign in" do
      let!(:clients) { create_list(:client, 4, :with_role)}
      it "should list client successfully" do
        set_auth_headers(auth_headers)

        get :index
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(clients.count)
      end
    end
  end
end
