require 'rails_helper'
require 'support/render_views'

RSpec.describe ClientEnrollmentServicesController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  let!(:role) { create(:role, name: 'executive_director', permissions: ['client_authorization_view', 'client_authorization_update', 'client_authorization_delete'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'test-organization', admin_id: user.id)}
  let!(:clinic) {create(:clinic, name: 'test-clinic', organization_id: organization.id)}
  let!(:client) { create(:client, clinic_id: clinic.id)}
  let!(:staff) { create(:staff, :with_role, role_name: 'bcba', clinics: [clinic])}
  let!(:funding_source) {create(:funding_source, clinic_id: clinic.id)}
  let!(:client_enrollment) { create(:client_enrollment, client_id: client.id, funding_source_id: funding_source.id)}
  let!(:service) { create(:service) }

  describe "POST #create" do
    context "when sign in" do
      it "should create client enrollment service successfully" do
        set_auth_headers(auth_headers)
        
        post :create, params: {
          client_id: client.id,
          funding_source_id: funding_source.id, 
          service_id: service.id,
          start_date: Date.today,
          end_date: Date.tomorrow,
          staff_id: staff.id
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_enrollment_id']).to eq(client_enrollment.id) 
        expect(response_body['data']['service_id']).to eq(service.id)
        expect(response_body['data']['start_date']).to eq(Date.today.to_s)
        expect(response_body['data']['end_date']).to eq(Date.tomorrow.to_s)
      end

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          post :create, params: { client_id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "when funding_source_id is not present" do
        let!(:client1){create(:client, clinic_id: clinic.id)}
        let!(:client_enrollment1){create(:client_enrollment, client_id: client1.id, source_of_payment: 'self_pay', funding_source_id: nil)}
        it "should create client enrollment service successfully" do
          set_auth_headers(auth_headers)
          
          post :create, params: {
            client_id: client1.id,
            service_id: service.id,
            start_date: Date.today,
            end_date: Date.tomorrow,
            staff_id: staff.id
          }
          response_body = JSON.parse(response.body)
  
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['client_enrollment_id']).to eq(client_enrollment1.id) 
          expect(response_body['data']['service_id']).to eq(service.id)
          expect(response_body['data']['start_date']).to eq(Date.today.to_s)
          expect(response_body['data']['end_date']).to eq(Date.tomorrow.to_s)
        end
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      let(:enrollment_service) { create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, service_id: service.id) }
      it "should fetch client enrollment service detail successfully" do
        set_auth_headers(auth_headers)

        get :show, params: {client_id: client.id, id: enrollment_service.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(enrollment_service.id) 
        expect(response_body['data']['client_enrollment_id']).to eq(client_enrollment.id) 
        expect(response_body['data']['service_id']).to eq(service.id)
      end

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          get :show, params: { client_id: 0, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "when id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          get :show, params: { client_id: client.id, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end
    end
  end

  describe "PUT #update" do
    context "when sign in" do
      let(:enrollment_service) { create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, service_id: service.id) }
      let(:service) { create(:service) }
      let(:funding_source) { create(:funding_source, clinic_id: clinic.id) }
      let(:client_enrollment) { create(:client_enrollment, client_id: client.id, funding_source_id: funding_source.id) }
      it "should update client enrollment service successfully" do
        set_auth_headers(auth_headers)
        
        put :update, params: {
          client_id: client.id,
          id: enrollment_service.id,
          service_id: service.id,
          start_date: Date.yesterday
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(enrollment_service.id) 
        expect(response_body['data']['service_id']).to eq(service.id)
        expect(response_body['data']['start_date']).to eq(Date.yesterday.to_s)
      end

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          put :update, params: { client_id: 0, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "when id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          put :update, params: { client_id: client.id, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "and update associated data" do
        it "should update client_enrollment_id successfully" do
          set_auth_headers(auth_headers)
        
          put :update, params: {
            client_id: client.id,
            id: enrollment_service.id,
            funding_source_id: funding_source.id
          }
          response_body = JSON.parse(response.body)
  
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(enrollment_service.id) 
          expect(response_body['data']['client_enrollment_id']).to eq(client_enrollment.id)
        end

        let!(:service1) { create(:service, is_service_provider_required: true) }
        let!(:staff){create(:staff, :with_role, role_name: 'bcba')}
        let!(:enrollment_service1) { create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, service_id: service1.id, service_providers_attributes: [{staff_id: staff.id}]) }
        let!(:staff){create(:staff, :with_role, role_name: 'rbt')}
        it "should update service providers successfully" do
          set_auth_headers(auth_headers)
        
          put :update, params: {
            client_id: client.id,
            id: enrollment_service1.id,
            service_providers_attributes: [{staff_id: staff.id}]
          }
          response_body = JSON.parse(response.body)
  
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(enrollment_service1.id) 
          expect(response_body['data']['service_providers'].count).to eq(1)
        end
      end 
    end
  end

  describe "DELETE #destroy" do
    context "when sign in" do
      let(:enrollment_service) { create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, service_id: service.id) }
      it "should delete client enrollment service detail successfully" do
        set_auth_headers(auth_headers)

        delete :destroy, params: { client_id: client.id, id: enrollment_service.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(enrollment_service.id)
        expect(ClientEnrollmentService.find_by_id(enrollment_service.id)).to eq(nil)
      end

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          delete :destroy, params: { client_id: 0, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "when id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          delete :destroy, params: { client_id: client.id, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end
    end
  end

  describe "PUT #replace_early_auth" do
    context "when sign in" do
      let!(:early_service) { create(:service, is_early_code: true, selected_non_early_service_id: service.id) }
      let!(:non_billable_funding_source) { create(:funding_source, clinic_id: clinic.id, network_status: 'non_billable') }
      let!(:client_enrollment1){ create(:client_enrollment, client_id: client.id, funding_source_id: non_billable_funding_source.id) }
      let!(:client_enrollment_service1){ create(:client_enrollment_service, client_enrollment_id: client_enrollment1.id, service_id: early_service.id, start_date: (Time.current - 5.days).to_date, end_date: (Time.current + 5.days).to_date) }
      let!(:scheduling1){ create(:scheduling, client_enrollment_service_id: client_enrollment_service1.id, date: (Time.current - 2.days).to_date, status: 'Auth_Pending', start_time: '10:00', end_time: '11:00', units: 4, staff_id: staff.id) }
      let!(:staff1){ create(:staff, :with_role, role_name: 'rbt') }
      let!(:scheduling2){ create(:scheduling, client_enrollment_service_id: client_enrollment_service1.id, date: (Time.current + 2.days).to_date, status: 'Scheduled', start_time: '10:00', end_time: '11:00', units: 4, staff_id: staff1.id) }
      let!(:staff2){ create(:staff, :with_role, role_name: 'bcba') }
      let!(:scheduling2){ create(:scheduling, client_enrollment_service_id: client_enrollment_service1.id, date: (Time.current + 2.days).to_date, status: 'Scheduled', start_time: '10:00', end_time: '11:00', units: 4, staff_id: staff2.id) }
      let!(:funding_source1) { create(:funding_source, clinic_id: clinic.id) }
      let!(:client_enrollment2) { create(:client_enrollment, client_id: client.id, funding_source_id: funding_source.id) }
      let!(:service1) { create(:service, is_service_provider_required: true, selected_payors: [{'payor_id': funding_source1.id, 'is_legacy_required': false}]) }
      let!(:client_enrollment_service2){ create(:client_enrollment_service, client_enrollment_id: client_enrollment2.id, service_id: service1.id, start_date: (Time.current - 5.days).to_date, end_date: (Time.current + 5.days).to_date, service_providers_attributes: [{staff_id: staff2.id}]) }
      it "should replace early auth by final auth successfully" do
        set_auth_headers(auth_headers)

        put :replace_early_auth, params: {early_authorization_id: client_enrollment_service1.id, final_authorization_id: client_enrollment_service2.id}
        expect(ClientEnrollmentService.find(client_enrollment_service2.id).schedulings.count).to eq(2)
        expect(ClientEnrollmentService.find_by_id(client_enrollment_service1.id)).not_to eq(nil)
      end
    end
  end
  
  describe "POST #create_early_auths" do
    context "when sign in" do
      let!(:user) {create(:user, :with_role, role_name: 'super_admin')}
      let!(:auth_headers){user.create_new_auth_token}
      let!(:funding_source) {create(:funding_source, network_status: 'non_billable')}
      let!(:services) {create_list(:service, 5, is_early_code: true)}
      it "should create source_of_payment and early authorizations successfully" do
        set_auth_headers(auth_headers)

        post :create_early_auths, params: {
          funding_source_id: funding_source.id,
          units: 500,
          client_id: client.id,
          service_ids: services.pluck(:id).first(3)
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).not_to eq(nil)
        expect(response_body['data']['funding_source_id']).to eq(funding_source.id)
        expect(response_body['data']['services'].count).to eq(3)
      end
    end
  end
end
