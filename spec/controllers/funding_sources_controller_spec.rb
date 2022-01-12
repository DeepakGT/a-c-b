require 'rails_helper'
require "support/render_views"

RSpec.describe FundingSourcesController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "GET #index" do
    let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
    let!(:auth_headers) { user.create_new_auth_token }
    let!(:organization) {create(:organization, name: 'org1', admin_id: user.id)}
    let!(:clinic) {create(:clinic, name: 'clinic1', organization_id: organization.id)}
    let!(:funding_sources) {create_list(:funding_source, 10, clinic_id: clinic.id)}
    context "when sign in" do
      it "should list funding sources successfully" do
        set_auth_headers(auth_headers)
        
        get :index, params: {clinic_id: clinic.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['total_records']).to eq(funding_sources.count)
      end

      it "should fetch the first page record by default" do
        set_auth_headers(auth_headers)
        
        get :index, params: {clinic_id: clinic.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq(1)
      end

      it "should fetch the given page record" do
        set_auth_headers(auth_headers)
        
        get :index, params: { page: 2, clinic_id: clinic.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq("2")
      end
    end
  end

  describe "POST #create" do
    let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
    let!(:auth_headers) { user.create_new_auth_token }
    let!(:organization) {create(:organization, name: 'org1', admin_id: user.id)}
    let!(:clinic) {create(:clinic, name: 'clinic1', organization_id: organization.id)}
    context "when sign in" do
      it "should create funding source successfully" do
        set_auth_headers(auth_headers)
        
        post :create, params: {clinic_id: clinic.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['clinic_id']).to eq(clinic.id)
      end
    end
  end

  describe "GET #show" do
    let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
    let!(:auth_headers) { user.create_new_auth_token }
    let!(:clinic) {create(:clinic, name: 'clinic1')}
    let!(:funding_source) {create(:funding_source, clinic_id: clinic.id)}
    context "when sign in" do
      it "should show funding source detail successfully" do
        set_auth_headers(auth_headers)
        
        get :show, params: {clinic_id: clinic.id, id: funding_source.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(funding_source.id)
      end
    end
  end

  describe "PUT #update" do
    let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
    let!(:auth_headers) { user.create_new_auth_token }
    let!(:clinic) {create(:clinic, name: 'clinic1')}
    let!(:funding_source) {create(:funding_source, clinic_id: clinic.id)}
    let!(:updated_funding_source_name) {'update-name'}
    context "when sign in" do
      it "should update funding source successfully" do
        set_auth_headers(auth_headers)
        
        put :update, params: {clinic_id: clinic.id, id: funding_source.id, name: updated_funding_source_name}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['name']).to eq(updated_funding_source_name)
      end
    end
  end
end
