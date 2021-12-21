require 'rails_helper'
require "support/render_views"

RSpec.describe StaffCredentialsController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "GET #index" do
    let!(:clinic) { create(:clinic, name: 'clinic1') }
    let!(:user) { create(:user, :with_role, role_name: 'rbt', clinic_id: clinic.id) }
    let!(:auth_headers) { user.create_new_auth_token }
    before do
      10.times { create(:staff_credential, staff_id: user.id) }
    end
    context "when sign in" do
      it "should fetch credential list successfully" do
        set_auth_headers(auth_headers)
        get :index, params: {staff_id: user.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(10)
      end
    end
  end

  describe "POST #create" do
    let!(:clinic) { create(:clinic, name: 'clinic1') }
    let!(:user) { create(:user, :with_role, role_name: 'rbt', clinic_id: clinic.id) }
    let!(:auth_headers) { user.create_new_auth_token }
    let!(:credential) { create(:credential) }
    context "when sign in" do
      it "should fetch credential list successfully" do
        set_auth_headers(auth_headers)
        post :create, params: {staff_id: user.id, credential_id: credential.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(user.reload.staff_credentials.first.id)
      end
    end
  end

  describe "GET #show" do
    let!(:clinic) { create(:clinic, name: 'clinic1') }
    let!(:user) { create(:user, :with_role, role_name: 'rbt', clinic_id: clinic.id) }
    let!(:auth_headers) { user.create_new_auth_token }
    let!(:staff_credential) { create(:staff_credential, staff_id: user.id) }
    context "when sign in" do
      it "should fetch staff-credential detail successfully" do
        set_auth_headers(auth_headers)
        get :show, params: {staff_id: user.id, id: staff_credential.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(staff_credential.id)
      end
    end
  end

  describe "PUT #update" do
    let!(:clinic) { create(:clinic, name: 'clinic1') }
    let!(:user) { create(:user, :with_role, role_name: 'rbt', clinic_id: clinic.id) }
    let!(:auth_headers) { user.create_new_auth_token }
    let!(:staff_credential) { create(:staff_credential, staff_id: user.id) }
    let!(:updated_cert_lic_number) { 'updated_cert_lic_number' }
    context "when sign in" do
      it "should update staff-credential successfully" do
        set_auth_headers(auth_headers)
        put :update, params: {staff_id: user.id, id: staff_credential.id, cert_lic_number: updated_cert_lic_number} 
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['cert_lic_number']).to eq(updated_cert_lic_number)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:clinic) { create(:clinic, name: 'clinic1') }
    let!(:user) { create(:user, :with_role, role_name: 'rbt', clinic_id: clinic.id) }
    let!(:auth_headers) { user.create_new_auth_token }
    let!(:staff_credential) { create(:staff_credential, staff_id: user.id) }
    context "when sign in" do
      it "should delete staff-credential successfully" do
        set_auth_headers(auth_headers)
        delete :destroy, params: {staff_id: user.id, id: staff_credential.id} 
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(staff_credential.id)
        expect(StaffCredential.find_by_id(staff_credential.id)).to eq(nil)
      end
    end
  end
end
