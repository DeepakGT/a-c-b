require 'rails_helper'
require "support/render_views"

RSpec.describe SchedulingMetaDataController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  let!(:user) { create(:user, :with_role) }
  let!(:auth_headers) { user.create_new_auth_token }

  describe "GET #selectable_options" do
    context "when sign in" do
      it "should fetch selectable options list successfully" do
        set_auth_headers(auth_headers)
        
        get :selectable_options
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['clients'].count).to eq(Client.all.count)
        expect(response_body['data']['staff'].count).to eq(Staff.all.count)
        expect(response_body['data']['services'].count).to eq(Service.all.count)
      end
    end
  end
end
