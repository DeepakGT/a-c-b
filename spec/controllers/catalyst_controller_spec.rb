require 'rails_helper'
require 'support/render_views'

RSpec.describe CatalystController, type: :controller do 
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  let!(:user){ create(:user, :with_role, role_name: 'super_admin') }
  let!(:auth_headers){ user.create_new_auth_token }
  let!(:organization) { create(:organization, name: 'org1', admin_id: user.id) }
  let!(:clinic) { create(:clinic, name: 'clinic1', organization_id: organization.id) }
  let!(:client) { create(:client, clinic_id: clinic.id, first_name: 'test', catalyst_patient_id: 'cbsdjefftggncjdnskcn') }
  let!(:service) { create(:service) }
  let!(:client_enrollment) { create(:client_enrollment, client_id: client.id) }
  let!(:client_enrollment_service) { create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, service_id: service.id) }
  let!(:staff) { create(:staff, :with_role, role_name: 'administrator', first_name: 'abcd', catalyst_user_id: 'mxkewdnufjfvntrjngujt') }

  describe "PUT #update_appointment_units" do
    context "when sign in" do
      context "and when catalyst and scheduling units does not match" do
        let(:scheduling) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:00', end_time: '13:00', units: 4, minutes: 60, unrendered_reason: ['units_does_not_match'], staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id)}
        let(:catalyst_data) {create(:catalyst_data, start_time: '12:30', end_time: '13:30', units: 4, minutes: 60, system_scheduling_id: scheduling.id, catalyst_patient_id: 'cbsdjefftggncjdnskcn', catalyst_user_id: 'mxkewdnufjfvntrjngujt')}
        it "should use catalyst units" do
          set_auth_headers(auth_headers)

          put :update_appointment_units, params: {scheduling_id: scheduling.id, catalyst_data_id: catalyst_data.id, use_catalyst_units: true}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(scheduling.id)
          expect(response_body['data']['date']).to eq((Time.current-5.days).strftime('%Y-%m-%d'))
          expect(response_body['data']['start_time']).to eq(catalyst_data.start_time)
          expect(response_body['data']['end_time']).to eq(catalyst_data.end_time)
          expect(response_body['data']['units']).to eq(catalyst_data.units)
          expect(response_body['data']['minutes']).to eq(catalyst_data.minutes)
          expect(response_body['data']['unrendered_reasons']).not_to include('units_does_not_match')
        end

        let(:scheduling) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:00', end_time: '13:00', units: 4, minutes: 60, unrendered_reason: ['units_does_not_match'], staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id)}
        let(:catalyst_data) {create(:catalyst_data, start_time: '12:30', end_time: '13:30', units: 4, minutes: 60, system_scheduling_id: scheduling.id, catalyst_patient_id: 'cbsdjefftggncjdnskcn', catalyst_user_id: 'mxkewdnufjfvntrjngujt')}
        it "should use abac units" do
          set_auth_headers(auth_headers)

          put :update_appointment_units, params: {scheduling_id: scheduling.id, catalyst_data_id: catalyst_data.id, use_abac_units: true}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(scheduling.id)
          expect(response_body['data']['date']).to eq((Time.current-5.days).strftime('%Y-%m-%d'))
          expect(response_body['data']['start_time']).to eq(scheduling.start_time)
          expect(response_body['data']['end_time']).to eq(scheduling.end_time)
          expect(response_body['data']['units']).to eq(scheduling.units)
          expect(response_body['data']['minutes']).to eq(scheduling.minutes)
          expect(response_body['data']['unrendered_reasons']).not_to include('units_does_not_match')
        end

        let(:scheduling) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:00', end_time: '13:00', units: 4, minutes: 60, unrendered_reason: ['units_does_not_match'], staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id)}
        let(:catalyst_data) {create(:catalyst_data, start_time: '12:30', end_time: '13:30', units: 4, minutes: 60, system_scheduling_id: scheduling.id, catalyst_patient_id: 'cbsdjefftggncjdnskcn', catalyst_user_id: 'mxkewdnufjfvntrjngujt')}
        it "should use custom units" do
          set_auth_headers(auth_headers)

          put :update_appointment_units, params: {scheduling_id: scheduling.id, catalyst_data_id: catalyst_data.id, use_custom_units: true, start_time: '12:15', end_time: '13:00', units: 3}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(scheduling.id)
          expect(response_body['data']['date']).to eq((Time.current-5.days).strftime('%Y-%m-%d'))
          expect(response_body['data']['start_time']).to eq('12:15')
          expect(response_body['data']['end_time']).to eq('13:00')
          expect(response_body['data']['units']).to eq(3.0)
          expect(response_body['data']['minutes']).to eq(45.0)
          expect(response_body['data']['unrendered_reasons']).not_to include('units_does_not_match')
        end
      end
    end
  end

  describe "PUT #assign_catalyst_note" do
    context "when sign in" do
      context "and multiple appointments are found for soap_note in catalyst" do
        context "and units of catalyst data and scheduling differ" do
          let(:scheduling1) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:00', end_time: '13:00', units: 4, minutes: 60, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id)}
          let(:scheduling2) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:05', end_time: '13:05', units: 4, minutes: 60, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id)}
          let(:catalyst_data) {create(:catalyst_data, start_time: '12:00', end_time: '12:45', units: 3, minutes: 45, catalyst_patient_id: 'cbsdjefftggncjdnskcn', catalyst_user_id: 'mxkewdnufjfvntrjngujt')}

          it "should assign soap note in catalyst to scheduling successfully" do
            set_auth_headers(auth_headers)

            put :assign_catalyst_note, params: {scheduling_id: scheduling1.id, catalyst_data_id: catalyst_data.id}
            response_body = JSON.parse(response.body)

            expect(response.status).to eq(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data']['id']).to eq(scheduling1.id)
            expect(response_body['data']['rendered_message']).not_to eq(nil)
            expect(response_body['data']['unrendered_reasons']).to include('units_does_not_match')
          end
        end

        context "and units of catalyst data and scheduling are equal" do
          let(:scheduling1) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:05', end_time: '13:00', units: 4, minutes: 55, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id)}
          let(:scheduling2) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:05', end_time: '13:05', units: 4, minutes: 60, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id)}
          let(:catalyst_data) {create(:catalyst_data, start_time: '12:00', end_time: '13:00', units: 4, minutes: 60, catalyst_patient_id: 'cbsdjefftggncjdnskcn', catalyst_user_id: 'mxkewdnufjfvntrjngujt')}

          it "should assign soap note in catalyst to scheduling successfully" do
            set_auth_headers(auth_headers)

            put :assign_catalyst_note, params: {scheduling_id: scheduling1.id, catalyst_data_id: catalyst_data.id}
            response_body = JSON.parse(response.body)

            expect(response.status).to eq(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data']['id']).to eq(scheduling1.id)
            expect(response_body['data']['rendered_message']).not_to eq(nil)
            expect(response_body['data']['is_rendered']).to eq(true)
          end
        end
      end
    end
  end

  describe "GET #catalyst_data_with_multiple_appointments" do
    context "when sign in" do
      context "and multiple appointments are found for soap_note in catalyst"
      let(:scheduling1) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:00', end_time: '13:00', units: 4, minutes: 60, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id)}
      let(:scheduling2) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '14:00', end_time: '15:00', units: 4, minutes: 60, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id)}
      let(:catalyst_data) {create(:catalyst_data, start_time: '12:30', end_time: '13:30', units: 4, minutes: 60, catalyst_patient_id: 'cbsdjefftggncjdnskcn', catalyst_user_id: 'mxkewdnufjfvntrjngujt')}

      it "should display all schedulings corresponding to catalyst data successfully" do
        set_auth_headers(auth_headers)

        get :catalyst_data_with_multiple_appointments, params: {id: catalyst_data.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(catalyst_data.id)
        expect(response_body['data']['date']).to eq(catalyst_data.date.to_time.strftime('%Y-%m-%d'))
        # expect(response_body['data']['appointments'].count).to eq(catalyst_data.multiple_schedulings_ids.count)
      end
    end
  end

  describe "GET #appointments_list" do
    context "when sign in" do
      let(:scheduling1) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:00', end_time: '13:00', units: 4, minutes: 60, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id)}
      let(:scheduling2) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '14:00', end_time: '15:00', units: 4, minutes: 60, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id)}
      let(:catalyst_data) {create(:catalyst_data, start_time: '12:30', end_time: '13:30', units: 4, minutes: 60, catalyst_patient_id: 'cbsdjefftggncjdnskcn', catalyst_user_id: 'mxkewdnufjfvntrjngujt')}
      let(:appointments) {Scheduling.on_date(catalyst_data.date)}

      it "should display all schedulings for date in catalyst data successfully" do
        set_auth_headers(auth_headers)

        get :appointments_list, params: {catalyst_data_id: catalyst_data.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(catalyst_data.id)
        expect(response_body['data']['date']).to eq(catalyst_data.date.to_time.strftime('%Y-%m-%d'))
        expect(response_body['data']['appointments'].count).to eq(appointments.count)
      end

      context "when location id is present" do
        let(:clinic) {create(:clinic)}
        let(:appointments) {Scheduling.on_date(catalyst_data.date).joins(client_enrollment_service: {client_enrollment: :client}).by_client_clinic(clinic.id)}

        it "should display all schedulings for date in catalyst data for specified location successfully" do
          set_auth_headers(auth_headers)
  
          get :appointments_list, params: {catalyst_data_id: catalyst_data.id, location_id: clinic.id}
          response_body = JSON.parse(response.body)
  
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(catalyst_data.id)
          expect(response_body['data']['date']).to eq(catalyst_data.date.to_time.strftime('%Y-%m-%d'))
          expect(response_body['data']['appointments'].count).to eq(appointments.count)
        end
      end
    end
  end

  describe "PUT #delete_catalyst_soap_note" do
    context "when sign in" do
      context "and catalyst soap note is not required in connect" do
        let(:catalyst_data) {create(:catalyst_data, start_time: '12:30', end_time: '13:30', units: 4, minutes: 60, catalyst_patient_id: 'cbsdjefftggncjdnskcn', catalyst_user_id: 'mxkewdnufjfvntrjngujt')}
        it "should hide catalyst soap note from dashboard" do
          set_auth_headers(auth_headers)
  
          get :delete_catalyst_soap_note, params: {catalyst_data_id: catalyst_data.id}
          response_body = JSON.parse(response.body)
  
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(catalyst_data.id)
          expect(response_body['data']['is_deleted_from_connect']).to eq(true)
        end
      end
    end
  end

  describe "GET #matching_appointments_list" do
    context "when sign in" do
      context "and adding new appointment for catalyat soap note with no appointment found as unrendered reason" do
        let!(:catalyst_data) {create(:catalyst_data, start_time: '12:30', end_time: '13:30', units: 4, minutes: 60, date: (Time.current-5.days).strftime('%Y-%m-%d'), catalyst_patient_id: 'cbsdjefftggncjdnskcn', catalyst_user_id: 'mxkewdnufjfvntrjngujt')}
        context "and best match exists" do
          let!(:scheduling1) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:20', end_time: '13:20', units: 4, minutes: 60, is_manual_render: true, status: 'rendered', rendered_at: Time.current, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id)}
          let!(:scheduling2) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '14:00', end_time: '15:15', units: 5, minutes: 75, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id)}
          it "should display best matching appointment successfully" do
            set_auth_headers(auth_headers)
  
            get :matching_appointments_list, params: {catalyst_data_id: catalyst_data.id}
            response_body = JSON.parse(response.body)
            
            expect(response.status).to eq(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data']['id']).to eq(catalyst_data.id)
            expect(response_body['data']['appointments'].count).to eq(1)
            expect(response_body['data']['appointments'].first['id']).to eq(scheduling1.id)
          end
        end
        
        context "and no match exists" do
          it "should not display any appointment" do
            set_auth_headers(auth_headers)
  
            get :matching_appointments_list, params: {catalyst_data_id: catalyst_data.id}
            response_body = JSON.parse(response.body)
    
            expect(response.status).to eq(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data']['id']).to eq(catalyst_data.id)
            expect(response_body['data']['appointments']).to eq(nil)
          end
        end
      end
    end
  end

  describe "PUT #appointment_with_multiple_soap_notes" do
    context "when sign in" do
      context "and multiple soap notes are associated to one appointment" do
        let!(:scheduling) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '14:00', end_time: '15:00', units: 4, minutes: 60, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id, unrendered_reason: ['multiple_soap_notes_found'])}
        let!(:catalyst_data1) {create(:catalyst_data, start_time: '14:30', end_time: '15:00', units: 2, minutes: 30, date: (Time.current-5.days).strftime('%Y-%m-%d'), catalyst_patient_id: 'cbsdjefftggncjdnskcn', catalyst_user_id: 'mxkewdnufjfvntrjngujt', session_location: 'Home', system_scheduling_id: scheduling.id)}
        let!(:soap_note1) { create(:soap_note, catalyst_data_id: catalyst_data1.id) }
        let!(:catalyst_data2) {create(:catalyst_data, start_time: '14:00', end_time: '14:30', units: 2, minutes: 30, date: (Time.current-5.days).strftime('%Y-%m-%d'), catalyst_patient_id: 'cbsdjefftggncjdnskcn', catalyst_user_id: 'mxkewdnufjfvntrjngujt', session_location: 'Home', system_scheduling_id: scheduling.id)}
        let!(:soap_note2) { create(:soap_note, catalyst_data_id: catalyst_data2.id) }
        let!(:catalyst_data3) {create(:catalyst_data, start_time: '15:00', end_time: '15:30', units: 2, minutes: 30, date: (Time.current-5.days).strftime('%Y-%m-%d'), catalyst_patient_id: 'cbsdjefftggncjdnskcn', catalyst_user_id: 'mxkewdnufjfvntrjngujt', session_location: 'Home', system_scheduling_id: scheduling.id)}
        let!(:soap_note3) { create(:soap_note, catalyst_data_id: catalyst_data3.id) }
        it "should assign selected catalyst soap notes to appointment" do
          scheduling.update(catalyst_data_ids: [catalyst_data1.id, catalyst_data2.id, catalyst_data3.id])
          
          set_auth_headers(auth_headers)
  
          put :appointment_with_multiple_soap_notes, params: {scheduling_id: scheduling.id, selected_catalyst_data_ids: [catalyst_data1.id, catalyst_data2.id]}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(scheduling.id)
          expect(response_body['data']['unrendered_reasons']).to eq([])
          expect(response_body['data']['is_rendered']).to eq(true)
          expect(response_body['data']['rendered_at']).not_to eq(nil)
          expect(catalyst_data3.reload.system_scheduling_id).to eq(nil)
        end
      end
    end
  end
end
