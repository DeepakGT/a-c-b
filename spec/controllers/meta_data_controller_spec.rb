require 'rails_helper'
require 'support/render_views'

RSpec.describe MetaDataController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  let!(:user) { create(:user, :with_role, role_name: 'super_admin') }
  let!(:auth_headers) { user.create_new_auth_token }

  describe "GET #selectable_options" do
    let!(:country_lists) { create_list(:country,6)}
    let!(:country) { create(:country, name: 'United States of America')}
    context "when sign in" do
      it "should fetch selectable options list successfully" do
        set_auth_headers(auth_headers)
        
        get :selectable_options
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['preferred_languages'].count).to eq(Client.preferred_languages.count)
        expect(response_body['data']['dq_reasons'].count).to eq(Client.dq_reasons.count)
        expect(response_body['data']['relation_types'].count).to eq(Contact.relation_types.count)
        expect(response_body['data']['relations'].count).to eq(Contact.relations.count)
        expect(response_body['data']['credential_types'].count).to eq(Qualification.credential_types.count)
        expect(response_body['data']['roles'].count).to eq(Role.where.not(name: 'super_admin').count)
        expect(response_body['data']['phone_types'].count).to eq(PhoneNumber.phone_types.count)
        expect(response_body['data']['country_list'].count).to eq(country_lists.count+1)
        expect(response_body['data']['source_of_payments'].count).to eq(ClientEnrollment.source_of_payments.count)
      end
    end
  end

  describe "GET #clinics_list" do
    context "when sign in" do
      let!(:clinics) { create_list(:clinic, 5) }
      context "when logged in user is super_admin" do
        it "should fetch all clinics successfully" do
          set_auth_headers(auth_headers)
          
          get :clinics_list
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(clinics.count)
        end 
      end

      context "when logged in user is staff" do
        let(:staff){ create(:staff, :with_role, role_name: 'bcba') }
        let(:staff_auth_headers) { staff.create_new_auth_token }
        let(:staff_clinic1){ create(:staff_clinic, clinic_id: clinics.last.id, staff_id: staff.id) }
        let(:staff_clinic2){ create(:staff_clinic, clinic_id: clinics.first.id, staff_id: staff.id) }
        it "should fetch clinics of that staff successfully" do
          set_auth_headers(staff_auth_headers)
          
          get :clinics_list
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(StaffClinic.where(staff_id: staff.id).count)
        end 
      end

      context "when logged in user is other than staff and super_admin" do
        let(:user1) { create(:user, :with_role, role_name: 'administrator') }
        let(:user_auth_headers) { user1.create_new_auth_token }
        it "should fetch clinic of that user successfully" do
          set_auth_headers(user_auth_headers)
          
          get :clinics_list
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(0)
        end 
      end
    end
  end

  describe "GET #bcba_list" do
    context "when sign in" do
      let!(:bcbas){ create_list(:staff, 5, :with_role, role_name: 'bcba') }
      it "should fetch bcba_list successfully" do
        set_auth_headers(auth_headers)
        
        get :bcba_list
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(bcbas.count)
      end 

      context "when clinic id is present in params" do
        let!(:clinic){ create(:clinic) }
        let!(:bcbas_list){ create_list(:staff, 5, :with_role, role_name: 'bcba') }
        let!(:staff_clinic1) { create(:staff_clinic, clinic_id: clinic.id, staff_id: bcbas_list.first.id)}
        let!(:staff_clinic2) { create(:staff_clinic, clinic_id: clinic.id, staff_id: bcbas_list.last.id)}
        it "should fetch bcba_list successfully" do
          set_auth_headers(auth_headers)
          
          get :bcba_list, params: {location_id: clinic.id}
          response_body = JSON.parse(response.body)
  
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(2)
        end 
      end
    end
  end
end
