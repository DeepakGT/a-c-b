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
        end 
      end
    end
  end

  describe "GET #rbt_list" do
    context "when sign in" do
      let!(:rbts){ create_list(:staff, 4, :with_role, role_name: 'rbt') }
      it "should fetch rbt_list successfully" do
        set_auth_headers(auth_headers)
        
        get :rbt_list
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(rbts.count)
      end 
    end
  end

  describe "GET #select_payor_types" do
    context "when the response is successful " do
      let!(:payor_types){ FundingSource.transform_payor_types }

      it "should get the selectable options from the payer successfully" do

        get :select_payor_types
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['payor_types']).to eq(payor_types)
      end
    end
  end
  
  describe "GET #services_and_funding_sources_list" do
    context "when sign in" do
      context "and is_early_code is selected" do
        let!(:funding_sources_list){create_list(:funding_source, 5, network_status: 'non_billable')}
        let!(:services_list){create_list(:service, 3, is_early_code: false)}
        it "should display non-early services and non billable funding sources list successfully" do
          set_auth_headers(auth_headers)

          get :services_and_funding_sources_list, params: {is_early_code: true}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['funding_sources'].count).to eq(funding_sources_list.count)
          expect(response_body['data']['non_early_services'].count).to eq(services_list.count)
        end
      end

      context "and is_early_code is not selected and rendering_provider_required is selected" do
        let!(:funding_sources_list){create_list(:funding_source, 5, network_status: 'in_network')}
        it "should display billable funding sources list successfully" do
          set_auth_headers(auth_headers)

          get :services_and_funding_sources_list, params: {is_early_code: false}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['funding_sources'].count).to eq(funding_sources_list.count)
          expect(response_body['data']['non_early_services']).to eq(nil)
        end
      end

      context "and client_id is present" do
        let!(:clinic) { create(:clinic) }
        let!(:client) { create(:client) }
        let!(:funding_source1){ create(:funding_source, clinic_id: clinic.id, network_status: 'non_billable') }
        let!(:funding_source2){ create(:funding_source, clinic_id: clinic.id, network_status: 'non_billable') }
        let!(:client_enrollment) { create(:client_enrollment, client_id: client.id, source_of_payment: 'insurance', funding_source_id: funding_source1.id) }
        it "should display non billable funding sources that have no client enrollment created" do
          set_auth_headers(auth_headers)

          get :services_and_funding_sources_list, params: {is_early_code: true, client_id: client.id}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['funding_sources'].count).to eq(1)
        end
      end
    end
  end

  describe 'GET #select_scheduling_status' do
    context 'when the response is successfully' do
      let!(:scheduling_statuses){ Scheduling.transform_statuses('') }

      it 'returns the selectable options from the scheduling status successfully' do

        get :select_scheduling_status, params: { action_type: '' }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['scheduling_statuses']).to eq(scheduling_statuses)
      end
    end
  end
end
