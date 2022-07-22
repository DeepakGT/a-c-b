require 'rails_helper'
require "support/render_views"

RSpec.describe StaffClinicsController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:role) { create(:role, name: 'billing', permissions: ['staff_location_view', 'staff_location_update', 'staff_location_delete'])}
  let!(:staff) { create(:staff, :with_role, role_name: role.name, last_name: 'Zachary') } 
  let!(:auth_headers) { staff.create_new_auth_token }
  let!(:organization) { create(:organization, name: 'org1') } 
  let!(:clinic1) { create(:clinic, name: 'clinic1', organization_id: organization.id) } 
  let!(:clinic2) { create(:clinic, name: 'clinic2', organization_id: organization.id) } 
  let!(:staff_clinic1) { create(:staff_clinic, staff_id: staff.id, clinic_id: clinic1.id, is_home_clinic: true) }
  let!(:staff_clinic2) { create(:staff_clinic, staff_id: staff.id, clinic_id: clinic2.id) }
  let!(:clinic3) { create(:clinic, name: 'clinic3', organization_id: organization.id)}
  let!(:clinic4) { create(:clinic, name: 'clinic4', organization_id: organization.id)}

  describe "GET #index" do
    context "when sign in" do
      it "should fetch staff clinics list successfully" do
        set_auth_headers(auth_headers)

        get :index, params: {staff_id: staff.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(2)    
      end
    end
  end

  describe "POST #create" do
    context "when sign in" do
      it "should create staff clinic successfully" do
        set_auth_headers(auth_headers)

        post :create, params: {
          staff_id: staff.id, 
          clinic_id: clinic3.id,
          is_home_clinic: false
        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['clinic_id']).to eq(clinic3.id)
        expect(response_body['data']['is_home_clinic']).to eq(false)
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      it "should fetch staff clinic detail successfully" do
        set_auth_headers(auth_headers)

        get :show, params: {staff_id: staff.id, id: staff_clinic1.id}
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(staff_clinic1.id)
      end
    end
  end
  
  describe "PUT #update" do
    context "when sign in" do
      it "should update staff clinic successfully" do
        set_auth_headers(auth_headers)

        put :update, params: {staff_id: staff.id, id: staff_clinic2.id, is_home_clinic: true}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(staff_clinic2.id)
        expect(response_body['data']['is_home_clinic']).to eq(true)    
      end
    end
  end

  describe "DELETE #destroy" do
    context "when sign in" do
      it "should delete staff clinic detail successfully" do
        set_auth_headers(auth_headers)

        delete :destroy, params: { staff_id: staff.id, id: staff_clinic1.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(staff_clinic1.id)
        expect(StaffClinic.find_by_id(staff_clinic1.id)).to eq(nil)    
      end

      context "and try to delete home clinic" do
        let!(:staff2) { create(:staff, :with_role, role_name: 'bcba') } 
        let!(:staff_clinic2){ create(:staff_clinic, clinic_id: clinic4.id, staff_id: staff2.id, is_home_clinic: true)}
        it "should give error" do
          set_auth_headers(auth_headers)
  
          delete :destroy, params: { staff_id: staff2.id, id: staff_clinic2.id }
          response_body = JSON.parse(response.body)
  
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('failure')
          expect(response_body['data']['id']).to eq(staff_clinic2.id)
          expect(StaffClinic.find_by_id(staff_clinic2.id)).not_to eq(nil) 
          expect(response_body['errors']).to eq(['Please add another home location first.'])   
        end
      end

      context "and try to delete staff clinic that is not home clinic" do
        it "should delete staff clinic detail successfully" do
          set_auth_headers(auth_headers)
  
          delete :destroy, params: { staff_id: staff.id, id: staff_clinic2.id }
          response_body = JSON.parse(response.body)
  
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(staff_clinic2.id)
          expect(StaffClinic.find_by_id(staff_clinic2.id)).to eq(nil)    
        end
      end
    end
  end
end
