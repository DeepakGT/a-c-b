require 'rails_helper'
require "support/render_views"

RSpec.describe SchedulingChangeRequestsController, type: :controller do 
  before :each do 
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do 
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:user) { create(:user, :with_role, role_name: 'super_admin') }
  let!(:auth_headers) { user.create_new_auth_token }

  describe "POST #create" do 
    context "when sign in" do 
      let!(:scheduling) {create(:scheduling)}
      it 'should create scheduling change request successfully' do 
        set_auth_headers(auth_headers)

        post :create, params: { scheduling_id: scheduling.id, date: Date.today, start_time: "10.00", end_time: "12.00", status: "Client_No_Show"}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['start_time']).to eq('10.00')
        expect(response_body['data']['status']).to eq('Client_No_Show')
      end
    end
  end

  describe "PUT #update" do 
    context "when sign in" do 
      let!(:scheduling) {create(:scheduling)}
      let!(:scheduling_change_request) {create(:scheduling_change_request, start_time: '3.00')}
      it 'should approved status successfully' do 
        set_auth_headers(auth_headers)

        put :update, params: { id: scheduling_change_request.id, scheduling_id: scheduling.id, approval_status: 'approve' }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['start_time']).to eq('3.00')
        expect(response_body['data']['approval_status']).to eq('approved')
      end

      it 'should declined status successfully' do 
        set_auth_headers(auth_headers)

        put :update, params: { id: scheduling_change_request.id, scheduling_id: scheduling.id, approval_status: 'decline' }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['approval_status']).to eq('declined')
      end
    end
  end
end
