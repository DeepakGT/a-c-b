require 'rails_helper'
require 'support/render_views'

RSpec.describe CatalystController, type: :controller do 
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  let!(:user){ create(:user, :with_role, role_name: 'super_admin') }
  let!(:auth_headers){ user.create_new_auth_token }

  describe "GET #sync_data" do
    context "when sign in" do
      it "should show data synced with catalyst successfully" do
        set_auth_headers(auth_headers)

        get :sync_data, params: {start_date: '01-01-2022', end_date: '01-02-2022'}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
      end
    end
  end
end
