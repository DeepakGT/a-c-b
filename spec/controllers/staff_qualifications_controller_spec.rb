require 'rails_helper'
require "support/render_views"

RSpec.describe StaffQualificationsController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  let!(:role) { create(:role, name: 'executive_director', permissions: ['staff_qualification_view', 'staff_qualification_update', 'staff_qualification_delete'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }

  describe "GET #index" do
    let!(:clinic) { create(:clinic, name: 'clinic1') }
    let!(:staff) { create(:staff, :with_role, role_name: 'rbt') }
    let!(:staff_clinic) { create(:staff_clinic, staff_id: staff.id, clinic_id: clinic.id) }
    before do
      10.times { create(:staff_qualification, staff_id: staff.id) }
    end
    context "when sign in" do
      it "should fetch qualification list successfully" do
        set_auth_headers(auth_headers)
        
        get :index, params: {staff_id: staff.id}
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(10)
      end
    end
  end

  describe "POST #create" do
    let!(:clinic) { create(:clinic, name: 'clinic1') }
    let!(:staff) { create(:staff, :with_role, role_name: 'rbt') }
    let!(:staff_clinic) { create(:staff_clinic, staff_id: staff.id, clinic_id: clinic.id) }
    let!(:qualification) { create(:qualification) }
    context "when sign in" do
      it "should fetch staff qualification list successfully" do
        set_auth_headers(auth_headers)

        post :create, params: {staff_id: staff.id, credential_id: qualification.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(staff.reload.staff_qualifications.first.id)
      end
    end
  end

  describe "GET #show" do
    let!(:clinic) { create(:clinic, name: 'clinic1') }
    let!(:staff) { create(:staff, :with_role, role_name: 'rbt') }
    let!(:staff_clinic) { create(:staff_clinic, staff_id: staff.id, clinic_id: clinic.id) }
    let!(:staff_qualification) { create(:staff_qualification, staff_id: staff.id) }
    context "when sign in" do
      it "should fetch staff-qualification detail successfully" do
        set_auth_headers(auth_headers)
        
        get :show, params: {staff_id: staff.id, id: staff_qualification.id}
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(staff_qualification.id)
      end
    end
  end

  describe "PUT #update" do
    let!(:clinic) { create(:clinic, name: 'clinic1') }
    let!(:staff) { create(:staff, :with_role, role_name: 'rbt') }
    let!(:staff_clinic) { create(:staff_clinic, staff_id: staff.id, clinic_id: clinic.id) }
    let!(:staff_qualification) { create(:staff_qualification, staff_id: staff.id) }
    let!(:updated_cert_lic_number) { 'updated_cert_lic_number' }
    context "when sign in" do
      it "should update staff-qualification successfully" do
        set_auth_headers(auth_headers)

        put :update, params: {staff_id: staff.id, id: staff_qualification.id, cert_lic_number: updated_cert_lic_number} 
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['cert_lic_number']).to eq(updated_cert_lic_number)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:clinic) { create(:clinic, name: 'clinic1') }
    let!(:staff) { create(:staff, :with_role, role_name: 'rbt') }
    let!(:staff_clinic) { create(:staff_clinic, staff_id: staff.id, clinic_id: clinic.id) }
    let!(:staff_qualification) { create(:staff_qualification, staff_id: staff.id) }
    context "when sign in" do
      it "should delete staff-qualification successfully" do
        set_auth_headers(auth_headers)

        delete :destroy, params: {staff_id: staff.id, id: staff_qualification.id} 
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(staff_qualification.id)
        expect(StaffQualification.find_by_id(staff_qualification.id)).to eq(nil)
      end
    end
  end
end
