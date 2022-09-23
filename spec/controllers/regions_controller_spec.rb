require 'rails_helper'
require "support/render_views"
RSpec.describe RegionsController, type: :controller do
  describe "GET #index" do
    let!(:role) { create(:role, name: 'executive_director', permissions: ['location_view', 'location_update'])}
    let!(:user) { create(:user, :with_role, role_name: role.name) }
    let!(:auth_headers) { user.create_new_auth_token }
    let!(:regions) { create_list(:region, 4)}
    context "when sign in" do
      it "should fetch regions list successfully" do
        set_auth_headers(auth_headers)
        get :index, format: :json
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(regions.count) 
      end
    end
  end
end