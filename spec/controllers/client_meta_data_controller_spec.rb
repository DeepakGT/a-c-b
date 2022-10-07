require 'rails_helper'
require 'support/render_views'

RSpec.describe ClientMetaDataController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:user) { create(:user, :with_role, role_name: 'executive_director') }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'test-organization', admin_id: user.id)}
  let!(:clinic) {create(:clinic, name: 'test-clinic', organization_id: organization.id)}
  let!(:client) { create(:client, clinic_id: clinic.id)}

  describe "GET #selectable_options" do
    context "when sign in" do
      it "should fetch client selectable options list successfully" do
        set_auth_headers(auth_headers)
        
        get :selectable_options, params: {client_id: client.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['services'].count).to eq(Service.all.count)
      end

      context "when early_authorization_id is present in params" do
        let!(:service){ create(:service) }
        let!(:early_service){ create(:service, is_early_code: true, selected_non_early_service_id: service.id) }
        let!(:funding_source){ create(:funding_source, clinic_id: clinic.id, network_status: 'non_billable')}
        let!(:client_enrollment){ create(:client_enrollment, client_id: client.id, funding_source_id: funding_source.id) }
        let!(:early_authorization){ create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, service_id: early_service.id) }
        it "should fetch non_early service for early service in early authorization successfully" do
          set_auth_headers(auth_headers)
        
          get :selectable_options, params: {client_id: client.id, early_authorization_id: early_authorization.id}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['services'].count).to eq(1)
          expect(response_body['data']['services'].first['id']).to eq(service.id)
        end
      end
    end
  end

  describe "GET #service_providers_list" do
    context "when sign in" do
      context "and service has no qualifications" do
        let(:service) { create(:service) }
        let(:service_providers) { clinic.staff.joins(:role).where('role.name': ['bcba', 'rbt']) }
        it "should fetch service providers list successfully." do
          set_auth_headers(auth_headers)

          get :service_providers_list, params: { client_id: client.id, service_id: service.id}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(service_providers.count)
        end
      end

      context "and service has qualifications" do
        let!(:service) {create(:service)}
        let!(:staff) {create(:staff, role_name: 'bcba')}
        let!(:staff_clinic) {create(:staff_clinic, staff_id: staff.id, clinic_id: clinic.id)}
        let!(:qualification) {create(:qualification)}
        let!(:service_qualification){create(:service_qualification, service_id: service.id, qualification_id: qualification.id)}
        let!(:staff_qualification){create(:staff_qualification, staff_id: staff.id, credential_id: qualification.id)}
        it "should fetch service providers list successfully." do
          set_auth_headers(auth_headers)
          
          get :service_providers_list, params: { client_id: client.id, service_id: service.id}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(1)
        end
      end
    end
  end

  describe "GET #client_data" do
    context "when sign in" do
      let!(:client_enrollment){ create(:client_enrollment, client_id: client.id) }
      let!(:client_enrollment_service){ create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, units: 200, minutes: 200*15) }
      let!(:client_enrollment_service1){ create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, units: 200, minutes: 200*15, start_date: '2022-01-01', end_date: '2022-04-30') }
      let!(:scheduling){ create(:scheduling, client_enrollment_service_id: client_enrollment_service.id) }
      let!(:soap_notes){ create_list(:soap_note, 5, scheduling_id: scheduling.id, user: user, client_id: client.id)}
      let!(:notes) { create_list(:client_note, 5, client_id: client.id)}
      let!(:attachments){ create_list(:attachment, 5, attachable_id: client.id, attachable_type: 'Client')}
      let!(:schedulings) {create_list(:scheduling, 3, units: '2', client_enrollment_service_id: client_enrollment_service.id, status: 'client_cancel_less_than_24_h')}
      it "should fetch client data detail successfully" do
        set_auth_headers(auth_headers)
        
        get :client_data, params: { client_id: client.id }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client.id)
        expect(response_body['data']['schedules'].count).to eq(Scheduling.includes(client_enrollment_service: :client_enrollment).by_client_ids(client.id).scheduled_scheduling.first(10).count)
        expect(response_body['data']['client_enrollment_services'].count).to eq(1)
        expect(response_body['data']['soap_notes'].count).to eq(soap_notes.first(10).count)
        expect(response_body['data']['notes'].count).to eq(notes.first(10).count)
        expect(response_body['data']['attachments'].count).to eq(attachments.first(10).count)
      end

      context "when show expired checkbox is selected" do
        it "should fetch client data detail successfully" do
          set_auth_headers(auth_headers)
          
          get :client_data, params: { client_id: client.id, show_expired_before_30_days: true }
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(client.id)
          expect(response_body['data']['schedules'].count).to eq(Scheduling.includes(client_enrollment_service: :client_enrollment).by_client_ids(client.id).scheduled_scheduling.first(10).count)
          expect(response_body['data']['client_enrollment_services'].count).to eq(2)
          expect(response_body['data']['soap_notes'].count).to eq(soap_notes.first(10).count)
          expect(response_body['data']['notes'].count).to eq(notes.first(10).count)
          expect(response_body['data']['attachments'].count).to eq(attachments.first(10).count)
        end
      end
    end
  end

  describe "GET #soap_notes" do
    context "when sign in" do
      let!(:soap_note) { create_list(:soap_note, 3, client_id: client.id) }
      it "should fetch soap notes list successfully" do
        set_auth_headers(auth_headers)
        
        get :soap_notes, params: { client_id: client.id, page: 2, per_page: 15 }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['total_records']).to eq(soap_note.count)
        expect(response_body['page']).to eq("2")
        expect(response_body['limit']).to eq(15)
      end
    end
  end

  describe "GET #soap_note_detail" do
    context "when sign in" do
      let!(:soap_note) { create(:soap_note, client_id: client.id) }
      it "should fetch soap note detail list successfully" do
        set_auth_headers(auth_headers)
        
        get :soap_note_detail, params: { id: soap_note.id, client_id: client.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['note']).to eq("test-note")
      end
    end
  end

  describe "GET #funding_sources_list" do
    context "when sign in" do
      context "and service is an early code" do
        let!(:service1){create(:service, is_early_code: true)}
        let!(:funding_source1){create(:funding_source, clinic_id: clinic.id, network_status: 'non_billable')}
        let!(:client_enrollment1){create(:client_enrollment, source_of_payment: 'insurance', funding_source_id: funding_source1.id, client_id: client.id)}
        it "should display non-billable funding sources list successfully" do
          set_auth_headers(auth_headers)

          get :funding_sources_list, params: {client_id: client.id, service_id: service1.id}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(1)
          expect(response_body['data'].first['id']).to eq(funding_source1.id)
        end
      end

      context "and service is not an early code" do
        let!(:service2){create(:service, is_early_code: false)}
        let!(:funding_source2){create(:funding_source, clinic_id: clinic.id, network_status: 'in_network')}
        let!(:client_enrollment1){create(:client_enrollment, source_of_payment: 'insurance', funding_source_id: funding_source2.id, client_id: client.id)}
        it "should display billable funding sources list successfully" do
          set_auth_headers(auth_headers)

          get :funding_sources_list, params: {client_id: client.id, service_id: service2.id}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(1)
          expect(response_body['data'].first['id']).to eq(funding_source2.id)
        end
      end
    end
  end
end
