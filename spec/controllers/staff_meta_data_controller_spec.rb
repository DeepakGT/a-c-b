require 'rails_helper'
require 'support/render_views'

RSpec.describe StaffMetaDataController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  let!(:clinic) { create(:clinic) }
  let!(:staff) { create(:staff, :with_role, role_name: 'bcba') }
  let!(:staff_clinic) { create(:staff_clinic, staff_id: staff.id, clinic_id: clinic.id) }
  let!(:auth_headers) { staff.create_new_auth_token }

  describe "GET #clients_list" do
    context "when sign in" do
      let!(:clients) { create_list(:client, 5, clinic_id: clinic.id) }
      it "should fetch client list of same clinic successfully" do
        set_auth_headers(auth_headers)
        
        get :clients_list
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(clients.count)
      end 
    end
  end
end
