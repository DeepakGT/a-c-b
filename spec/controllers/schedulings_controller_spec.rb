require 'rails_helper'
require "support/render_views"

RSpec.describe SchedulingsController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:role) { create(:role, name: 'aba_admin', permissions: ['scheduling_view', 'scheduling_update'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) { create(:organization, name: 'org1') }
  let!(:clinic) { create(:clinic, name: 'clinic1', organization_id: organization.id) }
  let!(:client) { create(:client, clinic_id: clinic.id) }
  let!(:service) { create(:service) }
  let!(:staff) { create(:staff, :with_role, role_name: 'bcba') }
  
  describe "GET #index" do
    context "when sign in" do
      let!(:schedulings) {create_list(:scheduling, 5)}
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
    end
  end

  describe "POST #create" do
    context "when sign in" do
      it "should create scheduling successfully" do
        set_auth_headers(auth_headers)
        
        post :create, params: {
          client_id: client.id,
          staff_id: staff.id,
          service_id: service.id,
          date: Time.now.to_date,
          status: 'scheduled',
          minutes: '288'
        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_id']).to eq(client.id)
        expect(response_body['data']['staff_id']).to eq(staff.id)
        expect(response_body['data']['service_id']).to eq(service.id)
        expect(response_body['data']['date']).to eq(Time.now.to_date.to_s)
        expect(response_body['data']['status']).to eq('scheduled')
        expect(response_body['data']['minutes']).to eq('288')
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      let(:scheduling) { create(:scheduling, client_id: client.id, staff_id: staff.id, service_id: service.id) }
      it "should fetch scheduling detail successfully" do
        set_auth_headers(auth_headers)
        
        get :show, params: { id: scheduling.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(scheduling.id)
        expect(response_body['data']['client_id']).to eq(client.id)
        expect(response_body['data']['staff_id']).to eq(staff.id)
        expect(response_body['data']['service_id']).to eq(service.id)
      end
    end
  end
end
