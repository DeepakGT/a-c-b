require 'rails_helper'
require "support/render_views"

RSpec.describe OrganizationsController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET #index" do 
    let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
    let!(:auth_headers) { user.create_new_auth_token }

    context "when sign in" do
      it "should list all organizations" do
        set_auth_headers(auth_headers)

        get :index
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
      end
    end
  end

  describe "GET #show" do 
    let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
    let!(:auth_headers) { user.create_new_auth_token }

    context "when sign in" do
      let(:organization) { create(:organization, name: 'test-organization')}
      it "should show organization" do
        set_auth_headers(auth_headers)

        get :show, params: {id: organization.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(organization.id)
      end
    end
  end
  
  describe "POST #create" do 
    let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
    let!(:auth_headers) { user.create_new_auth_token }

    context "when sign in" do
      let!(:organization_name){'test-organization-1'}
      it "should create an organization successfully" do
        set_auth_headers(auth_headers)

        post :create, params: {name: organization_name}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['name']).to eq(organization_name)
      end
    end
  end

  describe "PUT #update" do
    let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
    let!(:auth_headers) { user.create_new_auth_token }
    let!(:organization) {create(:organization, name: 'organization1')}

    context "when sign in" do
      let!(:updated_organization_name) {'organization-1-updated'}
      it "should update organization successfully" do
        set_auth_headers(auth_headers)
        put :update, params: {id: organization.id, name: updated_organization_name}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['name']).to eq(updated_organization_name)
      end

      let!(:organization) {create(:organization, name: 'organization1', address_attributes: {city: 'Bombay'})}
      let!(:updated_address_city) {'Indore'}
      context "and update associated data" do
        it "should update address successfully" do
          set_auth_headers(auth_headers)
          put :update, params: {id: organization.id, address_attributes: {city: updated_address_city} }
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['address']['city']).to eq(updated_address_city)
        end
      end
    end
  end
end
