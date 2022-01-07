require 'rails_helper'
require "support/render_views"

RSpec.describe ClinicsController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'org1', admin_id: user.id)}
    
  describe "GET #index" do
    context "when sign in" do
      let!(:clinics) { create_list(:clinic, 3)}
      it "should fetch client list successfully" do
        set_auth_headers(auth_headers)
        
        get :index
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['total_records']).to eq(clinics.count)
        #expect(response_body['data'].first).to eq(clinics.sort.first)
        #expect(response_body['data']).to be_sorted(by: :name)
        #expect(response_body['page']).to eq(1)
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

      let(:organization){ create(:organization, name: 'org2')}
      let(:clinic) { create(:clinic, organization_id: organization.id)}
      it "should fetch client list for a specific organization successfully" do
        set_auth_headers(auth_headers)

        get :index, params: {organization_id: organization.id}, :format => :json
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(organization.clinics.count)
      end
    end
  end

  describe "POST #create" do
    context "when sign in" do
      let(:clinic_name){'Test-clinic-1'}
      it "should create a clinic" do
        set_auth_headers(auth_headers)

        post :create, params: {organization_id: organization.id, name: clinic_name}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['name']).to eq(clinic_name)
        expect(response_body['data']['organization_id']).to eq(organization.id)
      end
    end
  end

  describe "PUT #update" do
    let!(:clinic) {create(:clinic, name: 'clinic1')}
    context "when sign in" do
      let!(:updated_clinic_name) {'clinic-1-updated'}
      it "should update clinic successfully" do
        set_auth_headers(auth_headers)
        put :update, params: {id: clinic.id, name: updated_clinic_name}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['name']).to eq(updated_clinic_name)
      end

      context "and update associated data" do
        let!(:updated_address_city) {'Indore'}
        let!(:updated_phone_number) {'9988776655'}

        it "should update address successfully" do
          set_auth_headers(auth_headers)
          put :update, params: {id: clinic.id, address_attributes: {city: updated_address_city} }
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['address']['city']).to eq(updated_address_city)
        end

        it "should update phone number successfully" do
          set_auth_headers(auth_headers)
          put :update, params: {id: clinic.id, phone_number_attributes: {number: updated_phone_number} }
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['phone_number']['number']).to eq(updated_phone_number)
        end
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      let(:clinic) {create(:clinic, name: 'Test-Clinic-1', address_attributes: {line1: 'test line'})}
      it "should show clinic detail successfully" do
        set_auth_headers(auth_headers)

        get :show, params: {id: clinic.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(clinic.id)
      end
    end
  end
end
