require 'rails_helper'
require "support/render_views"

RSpec.describe RolesController, type: :controller do
  before :each do
    request.headers["accept"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  let!(:user) { create(:user, :with_role, role_name: 'super_admin') }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:role_1) { create(:role, name: 'test-role-1')}
  let!(:role_2) { create(:role, name: 'test-role-2')}

  describe "GET #index" do
    context "when sign in" do
      it "should fetch roles list successfully" do
        set_auth_headers(auth_headers)

        get :index
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(Role.all.count) 
      end
    end
  end

  describe "POST #create" do
    context "when sign in" do
      it "should add role successfully" do
        set_auth_headers(auth_headers)

        post :create, params: {name: 'test_role'}
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['name']).to eq('test_role') 
      end
    end
  end

  describe "PUT #update" do
    context "when sign in" do
      let(:role) { create(:role, name: 'abcd')}
      it "should update role successfully" do
        set_auth_headers(auth_headers)
        
        put :update, params: { id: role.id, permissions: ["organization_view"]}
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(role.id)
        expect(response_body['data']['permissions']).to eq(["organization_view"])
      end

      context "and change_role_name is present" do
        let(:updated_role_name) {'ABCD'}
        it "should update role name" do
          set_auth_headers(auth_headers)

          put :update, params: { id: role.id, name: updated_role_name, change_role_name: true}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(role.id)
          expect(response_body['data']['name']).to eq(updated_role_name)
        end
      end

      context "and change_role_name is absent" do
        let(:updated_role_name) {'ABCD'}
        it "should not update role name" do
          set_auth_headers(auth_headers)

          put :update, params: { id: role.id, name: updated_role_name}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(role.id)
          expect(response_body['data']['name']).to eq(role.name)
        end
      end
    end
  end
  
  describe "GET #roles_list" do  
    context "when sign in" do 
      it "should list all roles" do
        set_auth_headers(auth_headers)
        
        get :roles_list
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(2)
      end
    end
  end
end
