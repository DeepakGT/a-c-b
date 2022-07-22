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
end
