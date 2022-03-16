require 'rails_helper'
require "support/render_views"

RSpec.describe ServicesController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:role) { create(:role, name: 'aba_admin', permissions: ['service_view', 'service_update'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:qualification) { create(:qualification) }
  
  describe "GET #index" do
    before do
      create(:service, name: 'service1')
      create(:service, name: 'service2')
    end
    context "when sign in" do
      it "should fetch services list successfully" do
        set_auth_headers(auth_headers)
        get :index
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['total_records']).to eq(2)
      end

      it "should fetch the first page record by default" do
        set_auth_headers(auth_headers)
        
        get :index
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq(1)
      end

      it "should fetch the given page record" do
        set_auth_headers(auth_headers)
        
        get :index, params: { page: 2}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq("2")
      end
    end
  end

  describe "POST #create" do
    context "when sign in" do
      let!(:service_name) {'test-service-1'}
      it "should create service successfully" do
        set_auth_headers(auth_headers)
        post :create, params: {
          name: service_name,
          display_code: 9485,
          service_qualifications_attributes: [{qualification_id: qualification.id}]
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['name']).to eq(service_name)
        expect(response_body['data']['display_code']).to eq("9485")
        expect(response_body['data']['qualification_ids'].count).to eq(1)
        expect(response_body['data']['qualification_ids'].first).to eq(qualification.id)
      end
    end
  end

  describe "PUT #update" do
    let!(:service) {create(:service, name: 'service1')}
    context "when sign in" do
      let!(:updated_service_name) {'service-1-updated'}
      it "should update service successfully" do
        set_auth_headers(auth_headers)

        put :update, params: {id: service.id, name: updated_service_name}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['name']).to eq(updated_service_name)
      end

      context "and update associated data" do
        it "should update service qualifications successfully" do
          set_auth_headers(auth_headers)
        
          put :update, params: {id: service.id, service_qualifications_attributes: [{qualification_id: qualification.id}] }
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(service.id)
          expect(response_body['data']['qualification_ids'].count).to eq(1)
          expect(response_body['data']['qualification_ids'].first).to eq(qualification.id)
        end
      end
    end
  end

  describe "GET #show" do
    let!(:service_name) {'service-1'}
    let!(:service) {create(:service, name: service_name)}
    context "when sign in" do
      it "should fetch service detail successfully" do
        set_auth_headers(auth_headers)
        get :show, params: {id: service.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(service.id)
        expect(response_body['data']['name']).to eq(service_name)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when sign in" do
      let(:user) { create(:user, :with_role, role_name: 'super_admin') }
      let(:auth_headers) { user.create_new_auth_token }
      let(:service) {create(:service, name: 'service1')}
      it "should delete service successfully" do
        set_auth_headers(auth_headers)

        delete :destroy, params: { id: service.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(service.id)
        expect(Service.find_by_id(service.id)).to eq(nil)
      end
    end
  end
end
