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

  describe "GET #sync_data" do
    context "when sign in" do
      it "should show data synced with catalyst successfully" do
        set_auth_headers(auth_headers)

        get :sync_data, params: {start_date: '01-01-2022', end_date: '01-02-2022'}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
      end
    end
  end

  describe "PUT #update_appointment_units" do
    context "when sign in" do
      context "and when catalyst and scheduling units does not match" do
        let(:scheduling) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:00', end_time: '13:00', units: 4, minutes: 60, unrendered_reason: ['units_does_not_match'])}
        let(:catalyst_data) {create(:catalyst_data, start_time: '12:30', end_time: '13:30', units: 4, minutes: 60, system_scheduling_id: scheduling.id)}
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

        let(:scheduling) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:00', end_time: '13:00', units: 4, minutes: 60, unrendered_reason: ['units_does_not_match'])}
        let(:catalyst_data) {create(:catalyst_data, start_time: '12:30', end_time: '13:30', units: 4, minutes: 60, system_scheduling_id: scheduling.id)}
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

        let(:scheduling) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:00', end_time: '13:00', units: 4, minutes: 60, unrendered_reason: ['units_does_not_match'])}
        let(:catalyst_data) {create(:catalyst_data, start_time: '12:30', end_time: '13:30', units: 4, minutes: 60, system_scheduling_id: scheduling.id)}
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
      context "and multiple appointments are found for soap_note in catalyst"
      let(:scheduling1) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:00', end_time: '13:00', units: 4, minutes: 60)}
      let(:scheduling2) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '14:00', end_time: '15:00', units: 4, minutes: 60)}
      let(:catalyst_data) {create(:catalyst_data, start_time: '12:30', end_time: '13:30', units: 4, minutes: 60, multiple_schedulings_ids: [scheduling1.id, scheduling2.id])}

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
  end

  describe "GET #catalyst_data_with_multiple_appointments" do
    context "when sign in" do
      context "and multiple appointments are found for soap_note in catalyst"
      let(:scheduling1) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:00', end_time: '13:00', units: 4, minutes: 60)}
      let(:scheduling2) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '14:00', end_time: '15:00', units: 4, minutes: 60)}
      let(:catalyst_data) {create(:catalyst_data, start_time: '12:30', end_time: '13:30', units: 4, minutes: 60, multiple_schedulings_ids: [scheduling1.id, scheduling2.id])}

      it "should display all schedulings corresponding to catalyst data successfully" do
        set_auth_headers(auth_headers)

        get :catalyst_data_with_multiple_appointments, params: {id: catalyst_data.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(catalyst_data.id)
        expect(response_body['data']['date']).to eq(catalyst_data.date.to_time.strftime('%Y-%m-%d'))
        expect(response_body['data']['appointments'].count).to eq(catalyst_data.multiple_schedulings_ids.count)
      end
    end
  end

  describe "GET #appointments_list" do
    context "when sign in" do
      let(:scheduling1) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '12:00', end_time: '13:00', units: 4, minutes: 60)}
      let(:scheduling2) {create(:scheduling, date: (Time.current-5.days).strftime('%Y-%m-%d'), start_time: '14:00', end_time: '15:00', units: 4, minutes: 60)}
      let(:catalyst_data) {create(:catalyst_data, start_time: '12:30', end_time: '13:30', units: 4, minutes: 60)}
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
end
