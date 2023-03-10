require 'rails_helper'
require "support/render_views"

RSpec.describe FundingSourcesController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:role) { create(:role, name: 'executive_director', permissions: ['funding_source_view', 'funding_source_update'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'org1')}
  let!(:clinic) {create(:clinic, name: 'clinic1', organization_id: organization.id)}
  
  describe "GET #index" do
    let!(:funding_sources) {create_list(:funding_source, 10, clinic_id: clinic.id)}
    context "when sign in" do
      it "should list funding sources successfully" do
        set_auth_headers(auth_headers)
        
        get :index, params: {clinic_id: clinic.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(funding_sources.count)
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

      let!(:updated_address_city) {'Indore'}
      context "and update associated data" do
        it "should update address successfully" do
          set_auth_headers(auth_headers)
          put :update, params: {clinic_id: clinic.id, id: funding_source.id, address_attributes: {city: updated_address_city} }
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['address']['city']).to eq(updated_address_city)
        end

        let!(:updated_phone_number) {'8989898989'}
        it "should update phone number successfully" do
          set_auth_headers(auth_headers)

          put :update, params: {clinic_id: clinic.id, id: funding_source.id, phone_number_attributes: {number: updated_phone_number} }
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['phone_number']['number']).to eq(updated_phone_number)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "when sign in" do
      let(:user) { create(:user, :with_role, role_name: 'super_admin') }
      let(:auth_headers) { user.create_new_auth_token }
      let(:funding_source) {create(:funding_source, clinic_id: clinic.id)}
      it "should delete funding source successfully" do
        set_auth_headers(auth_headers)

        delete :destroy, params: { clinic_id: clinic.id, id: funding_source.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(funding_source.id)
        expect(FundingSource.find_by_id(funding_source.id)).to eq(nil)
      end
    end
  end
end
