require 'rails_helper'
require "support/render_views"

RSpec.describe QualificationsController, type: :controller do
  before :each do
    request.headers["accept"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:role) { create(:role, name: 'executive_director', permissions: ['qualification_view', 'qualification_update'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }

  
  describe "GET #index" do  
    context "when sign in" do 
      let!(:qualifications) { create_list(:qualification, 10) }
      it "should list all qualification" do
        set_auth_headers(auth_headers)
        get :index
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(qualifications.count)
      end

      it "should list all qualifications on a specific page" do
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
      let!(:qualification) { create(:qualification, credential_type: 'education') }
      it "should create a qualification" do
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
      let(:qualification) { create(:qualification, credential_type: 'education') }

      it "should show qualification" do
        set_auth_headers(auth_headers)
      
        get :show, params: { id: qualification.id }
        
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(qualification.id)
        expect(response_body['data']['type']).to eq('education')
      end
    end
  end

  describe "PUT #update" do  
    context "when sign in" do
      let!(:qualification) { create(:qualification, credential_type: 'education') }
      it "should update qualification" do
        set_auth_headers(auth_headers)
        put :update, params: { id: qualification.id, credential_type: 'certification' }

        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['type']).to eq('certification')
      end
    end
  end

  describe "GET #types" do  
    context "when sign in" do
      it "should list all credential types" do
        set_auth_headers(auth_headers)
        
        get :types
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].map{|hash| hash['type']}).to match_array Qualification.credential_types.keys
        expect(response_body['data'].map{|hash| hash['id']}).to match_array Qualification.credential_types.values
        expect(response_body['data']).to be_a_kind_of(Array)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when sign in" do
      let(:user) { create(:user, :with_role, role_name: 'super_admin') }
      let(:auth_headers) { user.create_new_auth_token }
      let(:qualification) { create(:qualification, credential_type: 'education') }
      it "should delete qualification successfully" do
        set_auth_headers(auth_headers)

        delete :destroy, params: { id: qualification.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(qualification.id)
        expect(Qualification.find_by_id(qualification.id)).to eq(nil)
      end
    end
  end
end
