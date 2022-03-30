require 'rails_helper'
require "support/render_views"

RSpec.describe SchedulingsController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:role) { create(:role, name: 'aba_admin', permissions: ['schedule_view', 'schedule_update', 'schedule_delete'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) { create(:organization, name: 'org1') }
  let!(:clinic) { create(:clinic, name: 'clinic1', organization_id: organization.id) }
  let!(:client) { create(:client, clinic_id: clinic.id, first_name: 'test') }
  let!(:service) { create(:service) }
  let!(:client_enrollment) { create(:client_enrollment, client_id: client.id) }
  let!(:client_enrollment_service) { create(:client_enrollment_service, client_enrollment_id: client_enrollment.id) }
  let!(:staff) { create(:staff, :with_role, role_name: 'bcba', first_name: 'abcd') }
  
  describe "GET #index" do
    context "when sign in" do
      let!(:schedulings) {create_list(:scheduling, 5, units: '2')}
      it "should list schedulings successfully" do
        set_auth_headers(auth_headers)
        
        get :index
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['total_records']).to eq(schedulings.count)
      end

      it "should fetch the first page record by default" do
        set_auth_headers(auth_headers)
        
        get :index
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq(1)
      end

      it "should fetch the given page record" do
        set_auth_headers(auth_headers)
        
        get :index, params: { page: 2 }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq("2")
      end

      it "should staff filter by client ids successfully" do
        set_auth_headers(auth_headers)
        
        get :index, params: { client_ids: client.id }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(Scheduling.by_client_ids(client.id).count)
      end

      it "should staff filter by staff ids successfully" do
        set_auth_headers(auth_headers)
        
        get :index, params: { staff_ids: staff.id }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(Scheduling.by_staff_ids(staff.id).count)
      end

      it "should list staff filtered by service ids successfully" do
        set_auth_headers(auth_headers)

        get :index, params: { service_ids: service.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(Scheduling.by_service_ids(service.id).count)
      end
    end
  end

  describe "POST #create" do
    context "when sign in" do
      it "should create scheduling successfully" do
        set_auth_headers(auth_headers)
        
        post :create, params: {
          client_enrollment_service_id: client_enrollment_service.id,
          staff_id: staff.id,
          date: Time.now.to_date,
          start_time: '16:00',
          end_time: '17:00',
          status: 'scheduled',
          minutes: '288'
        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_enrollment_service_id']).to eq(client_enrollment_service.id)
        expect(response_body['data']['staff_id']).to eq(staff.id)
        expect(response_body['data']['date']).to eq(Time.now.to_date.to_s)
        expect(response_body['data']['start_time']).to eq('16:00')
        expect(response_body['data']['end_time']).to eq('17:00')
        expect(response_body['data']['status']).to eq('scheduled')
        expect(response_body['data']['minutes']).to eq(288.0)
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      let(:scheduling) { create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, staff_id: staff.id, date: '2022-02-28', start_time: '9:00', end_time: '10:00', units: '2') }
      it "should fetch scheduling detail successfully" do
        set_auth_headers(auth_headers)
        
        get :show, params: { id: scheduling.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(scheduling.id)
        expect(response_body['data']['client_enrollment_service_id']).to eq(client_enrollment_service.id)
        expect(response_body['data']['staff_id']).to eq(staff.id)
      end
    end
  end

  describe "PUT #update" do
    context "when sign in" do
      let(:scheduling) { create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, staff_id: staff.id, start_time: '12:00', end_time: '13:00', units: '2') }
      it "should update scheduling successfully" do
        set_auth_headers(auth_headers)

        put :update, params: { id: scheduling.id, status: 'unavailable', end_time: '14:00' }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(scheduling.id)
        expect(response_body['data']['status']).to eq('unavailable')
        expect(response_body['data']['end_time']).to eq('14:00')
      end

      context "and update associated data" do
        let(:staff) { create(:staff, :with_role, role_name: 'rbt') }
        it "should update associated staff successfully" do
          set_auth_headers(auth_headers)

          put :update, params: { id: scheduling.id, staff_id: staff.id }
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(scheduling.id)
          expect(response_body['data']['staff_id']).to eq(staff.id)
        end

        let(:client_enrollment_service) { create(:client_enrollment_service) }
        it "should update associated client enrollment service successfully" do
          set_auth_headers(auth_headers)

          put :update, params: { id: scheduling.id, client_enrollment_service_id: client_enrollment_service.id }
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(scheduling.id)
          expect(response_body['data']['client_enrollment_service_id']).to eq(client_enrollment_service.id)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "when sign in" do
      let(:scheduling) { create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, staff_id: staff.id, start_time: '17:00', end_time: '18:00', units: '2') }
      it "should delete scheduling detail successfully" do
        set_auth_headers(auth_headers)

        delete :destroy, params: { id: scheduling.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(scheduling.id)
        expect(Scheduling.find_by_id(scheduling.id)).to eq(nil)    
      end
    end
  end
end
