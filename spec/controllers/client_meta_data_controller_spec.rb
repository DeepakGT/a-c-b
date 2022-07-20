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
      # let(:client_enrollments) { client.client_enrollments.active.where.not(source_of_payment: 'self_pay') }
      it "should fetch client selectable options list successfully" do
        set_auth_headers(auth_headers)
        
        get :selectable_options, params: {client_id: client.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['services'].count).to eq(Service.all.count)
        # expect(response_body['data']['funding_sources'].count).to eq(client_enrollments.count)
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
      let!(:client_enrollment_service){ create(:client_enrollment_service, client_enrollment_id: client_enrollment.id) }
      let!(:scheduling){ create(:scheduling, client_enrollment_service_id: client_enrollment_service.id) }
      let!(:soap_notes){ create_list(:soap_note, 5, scheduling_id: scheduling.id, user: user)}
      let!(:notes) { create_list(:client_note, 5, client_id: client.id)}
      let!(:attachments){ create_list(:attachment, 5, attachable_id: client.id, attachable_type: 'Client')}
      it "should fetch client data detail successfully" do
        set_auth_headers(auth_headers)
        
        get :client_data, params: { client_id: client.id }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client.id)
        expect(response_body['data']['schedules'].count).to eq(1)
        expect(response_body['data']['client_enrollment_services'].count).to eq(1)
        expect(response_body['data']['soap_notes'].count).to eq(soap_notes.first(10).count)
        expect(response_body['data']['notes'].count).to eq(notes.first(10).count)
        expect(response_body['data']['attachments'].count).to eq(attachments.first(10).count)
      end
    end
  end
end
