require 'rails_helper'
require "support/render_views"

RSpec.describe RolesController, type: :controller do
  before :each do
    request.headers["accept"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:user) { create(:user, :with_role, role_name: 'administrator') }
  let!(:auth_headers) { user.create_new_auth_token }
  
  describe "GET #index" do  
    context "when sign in" do 
      let!(:role) { create(:role) }
      it "should list all roles" do
        set_auth_headers(auth_headers)
        
        @roles = [FactoryBot.build_stubbed(:role)]
        allow(Role).to receive(:all).and_return(@roles)
        get :index

        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].first['name']).to eq('aba_admin')
      end
    end
  end
end
