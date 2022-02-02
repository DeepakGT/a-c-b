require 'rails_helper'
require "support/render_views"

RSpec.describe RolesController, type: :controller do
  before :each do
    request.headers["accept"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  let!(:role) { create(:role, permissions: ['roles_index'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  
  describe "GET #roles_list" do  
    context "when sign in" do 
      it "should list all roles" do
        set_auth_headers(auth_headers)
        
        @roles = [FactoryBot.build_stubbed(:role)]
        allow(Role).to receive(:all).and_return(@roles)
        get :roles_list

        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].first['name']).to eq('aba_admin')
      end
    end
  end
end
