require 'rails_helper'
require "support/render_views"

RSpec.describe SchedulingMetaDataController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  let!(:user) { create(:user, :with_role) }
  let!(:auth_headers) { user.create_new_auth_token }

  describe "GET #selectable_options" do
    context "when sign in" do
      it "should fetch selectable options list successfully" do
        set_auth_headers(auth_headers)
        
        get :selectable_options
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['clients'].count).to eq(Client.all.count)
        expect(response_body['data']['staff'].count).to eq(Staff.all.count)
        expect(response_body['data']['services'].count).to eq(Service.all.count)
      end

      context "when clinic is present" do
        let(:clinic) { create(:clinic) }
        it "should fetch selectable options list according to clinic successfully" do
          set_auth_headers(auth_headers)
        
          get :selectable_options, params: { location_id: clinic.id }
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['clients'].count).to eq(Client.all.count)
          expect(response_body['data']['staff'].count).to eq(Staff.all.count)
          expect(response_body['data']['services'].count).to eq(Service.all.count)
        end
      end
    end
  end

  describe "GET #services_list" do
    context "when sign in" do
      let!(:client) { create(:client) }
      let!(:qualification) { create(:qualification) }
      let!(:staff) { create(:staff, :with_role, role_name: 'bcba') }
      let!(:staff_qualification) { create(:staff_qualification, staff_id: staff.id, credential_id: qualification.id) }
      let!(:service1){ create(:service, is_service_provider_required: true, service_qualifications_attributes: [{qualification_id: qualification.id}])}
      let!(:service2){ create(:service, is_service_provider_required: false, service_qualifications_attributes: [{qualification_id: qualification.id}])}
      let!(:client_enrollment){ create(:client_enrollment, client_id: client.id) }
      let!(:client_enrollment_service1){create(:client_enrollment_service, service_id: service1.id, client_enrollment_id: client_enrollment.id, service_providers_attributes: [{staff_id: staff.id}])}
      let!(:client_enrollment_service2){create(:client_enrollment_service, service_id: service2.id, client_enrollment_id: client_enrollment.id)}
      it "should list all authorization services list successfully" do
        set_auth_headers(auth_headers)
        
        get :services_list, params: { client_id: client.id, staff_id: staff.id, date: Time.current.to_date }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(2)
      end

      context "when staff has no qualifications" do
        let!(:staff1){ create(:staff, :with_role, role_name: 'bcba') }
        let!(:service3) {create(:service)}
        let!(:client_enrollment_service3){create(:client_enrollment_service, service_id: service3.id, client_enrollment_id: client_enrollment.id, start_date: Time.current.to_date-10, end_date: Time.current.to_date+7)}
        it "should list all authorization services list that require no qualifications" do
          set_auth_headers(auth_headers)
        
          get :services_list, params: { client_id: client.id, staff_id: staff1.id, date: Time.current.to_date }
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(1)
        end
      end

      context "when staff_id is not present" do
        let!(:service4) {create(:service, is_unassigned_appointment_allowed: true)}
        let!(:client_enrollment_service3){create(:client_enrollment_service, service_id: service4.id, client_enrollment_id: client_enrollment.id, start_date: Time.current.to_date-10, end_date: Time.current.to_date+7)}
        it "should list all authorization service list that have unassigned appointments allowed" do
          set_auth_headers(auth_headers)
        
        get :services_list, params: { client_id: client.id, date: Time.current.to_date }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(1)
        end
      end
    end
  end

  describe "GET #rbt_appointments" do
    context "when sign in" do
      let!(:staff1){ create(:staff, :with_role, role_name: 'rbt', catalyst_user_id: 'abcdefncnecnjdjk') }
      let!(:auth_headers){ staff1.create_new_auth_token }
      let(:clinic){ create(:clinic) }
      let!(:client){ create(:client, clinic_id: clinic.id, catalyst_patient_id: 'nytreszxcvbnmjhyt', first_name: 'test1', last_name: 'client') }
      let!(:client_enrollment){ create(:client_enrollment, client_id: client.id) }
      let!(:client_enrollment_service){ create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, start_date: Time.current.to_date-2, end_date: Time.current.to_date+5) }
      let!(:scheduling1){create(:scheduling, staff_id: staff1.id, date: Time.current.to_date-2, client_enrollment_service_id: client_enrollment_service.id)}
      let!(:catalyst_data1){create(:catalyst_data, date: Time.current.to_date-3, catalyst_user_id: 'abcdefncnecnjdjk', catalyst_patient_id: 'nytreszxcvbnmjhyt')}
      let!(:scheduling2){create(:scheduling, staff_id: staff1.id, date: Time.current.to_date, client_enrollment_service_id: client_enrollment_service.id)}
      let!(:client1){ create(:client, clinic_id: clinic.id, catalyst_patient_id: 'zssertfdszdesa', first_name: 'test2', last_name: 'client') }
      let!(:catalyst_data2){create(:catalyst_data, date: Time.current.to_date-3, catalyst_user_id: 'abcdefncnecnjdjk', catalyst_patient_id: 'zssertfdszdesa')}
      it "should fetch rbt appointment list successfully" do
        set_auth_headers(auth_headers)
        
        get :rbt_appointments
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['action_items'].count).to eq(3)
      end

      context "when sortSoapNoteByDate is present and sortSoapNoteByClient is present" do
        it "should sort action items by client name and date in ascending order successfully" do
          set_auth_headers(auth_headers)
        
          get :rbt_appointments, params: {sortSoapNoteByClient: 1, sortSoapNoteByDate: 1}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['action_items'].count).to eq(3)
          expect(response_body['data']['action_items'].first['client_name']).to eq('test1 client')
          expect(response_body['data']['action_items'].last['client_name']).to eq('test2 client')
          expect(response_body['data']['action_items'].first['date']).to eq((Time.current-3.days).strftime('%Y-%m-%d'))
        end
      end

      context "when sortSoapNoteByDate is absent and sortSoapNoteByClient is present" do
        it "should sort action items by client name in ascending order successfully" do
          set_auth_headers(auth_headers)
        
          get :rbt_appointments, params: {sortSoapNoteByClient: 1}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['action_items'].count).to eq(3)
          expect(response_body['data']['action_items'].first['client_name']).to eq('test1 client')
        end

        it "should sort action items by client name in descending order successfully" do
          set_auth_headers(auth_headers)
        
          get :rbt_appointments, params: {sortSoapNoteByClient: 0}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['action_items'].count).to eq(3)
          expect(response_body['data']['action_items'].first['client_name']).to eq('test2 client')
        end
      end

      context "when sortSoapNoteByDate is present and sortSoapNoteByClient is absent" do
        it "should sort action items by date in ascending order successfully" do
          set_auth_headers(auth_headers)
        
          get :rbt_appointments, params: {sortSoapNoteByDate: 1}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['action_items'].count).to eq(3)
          expect(response_body['data']['action_items'].first['date']).to eq((Time.current-3.days).strftime('%Y-%m-%d'))
        end

        it "should sort action items by date in descending order successfully" do
          set_auth_headers(auth_headers)
        
          get :rbt_appointments, params: {sortSoapNoteByDate: 0}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['action_items'].count).to eq(3)
          expect(response_body['data']['action_items'].first['date']).to eq((Time.current-2.days).strftime('%Y-%m-%d'))
        end
      end
    end
  end

  describe "GET #bcba_appointments" do
    context "when sign in" do
      let!(:staff2){ create(:staff, :with_role, role_name: 'bcba') }
      let!(:staff2_auth_headers){ staff2.create_new_auth_token }
      let!(:client){ create(:client, bcba_id: staff2.id) }
      let!(:client_enrollment){ create(:client_enrollment, client_id: client.id) }
      let!(:client_enrollment_service){ create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, start_date: Time.current.to_date-2, end_date: Time.current.to_date+5) }

      let!(:scheduling1){create(:scheduling, staff_id: staff2.id, date: Time.current.to_date-2, client_enrollment_service_id: client_enrollment_service.id)}
      let!(:scheduling2){create(:scheduling, staff_id: staff2.id, date: Time.current.to_date, client_enrollment_service_id: client_enrollment_service.id)}
      it "should fetch bcba appointment list successfully" do
        set_auth_headers(staff2_auth_headers)
        
        get :bcba_appointments
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['action_items'].count).to eq(1)
        expect(response_body['data']['client_enrollment_services'].count).to eq(1)
      end
    end
  end

  describe "GET #executive_director_appointments" do
    context "when sign in" do
      let!(:user){ create(:staff, :with_role, role_name: 'executive_director') }
      let!(:user_auth_headers){ user.create_new_auth_token }
      let(:clinic){ create(:clinic) }
      let!(:client){ create(:client, clinic_id: clinic.id) }
      let!(:client_enrollment){ create(:client_enrollment, client_id: client.id) }
      let!(:client_enrollment_service){ create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, start_date: Time.current.to_date-2, end_date: Time.current.to_date+5) }
      let!(:client_enrollment_service1){ create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, start_date: Time.current.to_date-30, end_date: Time.current.to_date+30) }
      let!(:scheduling1){create(:scheduling, date: Time.current.to_date-2, client_enrollment_service_id: client_enrollment_service1.id)}
      let!(:scheduling2){create(:scheduling, date: Time.current.to_date, client_enrollment_service_id: client_enrollment_service1.id)}
      it "should fetch executive_director appointment list successfully" do
        set_auth_headers(user_auth_headers)
        
        get :executive_director_appointments, params: { default_location_id: clinic.id }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['todays_schedules'].count).to eq(1)
        expect(response_body['data']['action_items'].count).to eq(1)
        expect(response_body['data']['client_enrollment_services'].count).to eq(1)
      end
    end
  end

  describe "GET #billing_dashboard" do
    context "when sign in" do
      let!(:clinic){ create(:clinic) }
      let!(:client){ create(:client, clinic_id: clinic.id) }
      let!(:funding_source) { create(:funding_source, clinic_id: clinic.id) }
      let!(:client_enrollment){ create(:client_enrollment, client_id: client.id, funding_source_id: funding_source.id) }  
      let!(:service) { create_list(:service, 2, display_code: '97151') }

      let!(:client_enrollment_service){ create_list(:client_enrollment_service, 2, start_date: (Time.current.to_date-40).to_time.strftime('%Y-%m-%d'), client_enrollment_id: client_enrollment.id, service_id: service.last.id) }  

      let!(:client_enrollment_service0){ create_list(:client_enrollment_service, 2, start_date: (Time.current.to_date-5).to_time.strftime('%Y-%m-%d'), client_enrollment_id: client_enrollment.id, service_id: service.last.id) } 

      let!(:client_enrollment_service1){ create_list(:client_enrollment_service, 2,client_enrollment_id: client_enrollment.id, end_date: Time.current.to_date+2, service_id: service.last.id) }

      let!(:client_enrollment_service2){ create_list(:client_enrollment_service, 2, start_date: Time.current.to_date-10, client_enrollment_id: client_enrollment.id, end_date: Time.current.to_date+6, service_id: service.first.id) }

      let!(:client_enrollment_service3){ create_list(:client_enrollment_service, 2, client_enrollment_id: client_enrollment.id, start_date: Time.current.to_date-30, end_date: Time.current.to_date+10, service_id: service.last.id) }
          
      it "should list billing_dashboard successfully" do
        set_auth_headers(auth_headers)
            
        get :billing_dashboard
        response_body = JSON.parse(response.body)
          
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['authorizations_expire_in_5_days'].count).to eq(6)
        expect(response_body['data']['authorizations_renewal_in_5_to_20_days'].count).to eq(2)
        expect(response_body['data']['authorizations_renewal_in_21_to_60_days'].count).to eq(2)
        expect(response_body['data']['client_with_no_authorizations'].count).to eq(0)
        expect(response_body['data']['client_with_only_97151_service_authorization'].count).to eq(1)
      end
    end 
  end

  describe "GET #unassigned_catalyst_soap_notes" do
    context "when sign in" do
      let!(:client){ create(:client) }
      let!(:scheduling){ create(:scheduling) }
      let!(:catalyst_data){ create_list(:catalyst_data, 2, catalyst_patient_id: client.catalyst_patient_id, date: scheduling.date, system_scheduling_id: nil) }
      it "should list unassigned_catalyst_soap_notes successfully" do
        set_auth_headers(auth_headers)
        
        get :unassigned_catalyst_soap_notes, params: { appointment_id: scheduling.id, client_id: client.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(2)
      end
    end
  end

  describe "GET #clients_and_staff_list_for_filter" do
    context "when sign in" do
      let!(:client_enrollment) { create(:client_enrollment) }
      context "clients list" do
        let!(:staff) { create(:staff, :with_role, role_name: 'bcba') }
        let!(:auth_headers){ staff.create_new_auth_token }
        let!(:client) { create(:client, status: 'active', first_name: 'abc') }
        let!(:client_enrollment_service){ create(:client_enrollment_service) }
        let!(:scheduling){ create(:scheduling, staff_id: staff.id) }
        it "should fetch clients_list successfully" do
          set_auth_headers(auth_headers)
          
          get :clients_and_staff_list_for_filter
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['clients'].count).to eq(1)
        end
      end

      context "staff list" do
        let!(:clinic) { create(:clinic) }
        let!(:staff) { create(:staff) }
        let!(:auth_headers){ staff.create_new_auth_token }
        let!(:staff_clinic) { create(:staff_clinic, staff_id: staff.id, clinic_id: clinic.id, is_home_clinic: true) }

        it "should fetch staff_list successfully" do
          set_auth_headers(auth_headers)
          
          get :clients_and_staff_list_for_filter, params: { location_id: clinic.id }
          response_body = JSON.parse(response.body)
        
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['staff'].count).to eq(1)
        end
      end

      context "service list" do
        let!(:service) { create_list(:service, 3) }
        let!(:staff) { create(:staff) }
        let!(:auth_headers){ staff.create_new_auth_token }
        it "should fetch service_list successfully" do
          set_auth_headers(auth_headers)
          
          get :clients_and_staff_list_for_filter
          response_body = JSON.parse(response.body)      
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['services'].count).to eq(3)
        end
      end
    end
  end
end
