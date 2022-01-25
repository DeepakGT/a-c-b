require 'rails_helper'
require "support/render_views"

RSpec.describe CredentialsController, type: :controller do
  before :each do
    request.headers["accept"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
  let!(:auth_headers) { user.create_new_auth_token }

  
  describe "GET #index" do  
    context "when sign in" do 
      let!(:credentials) { create_list(:credential, 10) }
      it "should list all credential" do
        set_auth_headers(auth_headers)
        get :index
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(credentials.count)
      end

      it "should list all credentials on a specific page" do
        set_auth_headers(auth_headers)

        get :index, params: { page: 2 }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq("2") 
      end
    end
  end
 
  describe "POST #create" do   
    context "when sign in" do
      it "should create a credential" do
        set_auth_headers(auth_headers)
        post :create, params: { 
          credential_type: 'certification',
          name: 'abcd',
          description: 'testing',
          lifetime: false
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['name']).to eq('abcd')
      end
    end
  end

  describe "GET #show" do  
    context "when sign in" do
      let(:credential) { create(:credential, credential_type: 'education') }

      it "should show credential" do
        set_auth_headers(auth_headers)
      
        get :show, params: { id: credential.id }
        
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(credential.id)
        expect(response_body['data']['type']).to eq('education')
      end
    end
  end

  describe "PUT #update" do  
    context "when sign in" do
      let!(:credential) { create(:credential, credential_type: 'education') }
      it "should update credential" do
        set_auth_headers(auth_headers)
        put :update, params: { id: credential.id, credential_type: 'certification' }

        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['type']).to eq('certification')
      end
    end
  end
end
