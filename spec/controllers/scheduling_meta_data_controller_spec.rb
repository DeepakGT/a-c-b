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
        
          get :selectable_options, params: { clinic_id: clinic.id }
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
        
        get :services_list, params: { client_id: client.id, staff_id: staff.id, date: Time.now.to_date }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(2)
      end
    end
  end

  describe "GET #rbt_appointments" do
    context "when sign in" do
      let!(:staff1){ create(:staff, :with_role, role_name: 'rbt') }
      let!(:auth_headers){ staff1.create_new_auth_token }
      let!(:scheduling1){create(:scheduling, staff_id: staff1.id, date: '2022-02-21')}
      let!(:scheduling2){create(:scheduling, staff_id: staff1.id, date: '2022-06-21')}
      it "should fetch rbt appointment list successfully" do
        set_auth_headers(auth_headers)
        
        get :rbt_appointments
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['upcoming_schedules'].count).to eq(1)
        expect(response_body['data']['past_schedules'].count).to eq(1)
      end
    end
  end
end
