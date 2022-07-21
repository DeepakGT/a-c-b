require 'rails_helper'
require 'support/render_views'

RSpec.describe StaffMetaDataController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe "GET #clients_list" do
    context "when sign in" do
      context "when logged in user is rbt" do
        let!(:clinic) { create(:clinic) }
        let!(:staff) { create(:staff, :with_role, role_name: 'rbt') }
        let!(:staff_clinic) { create(:staff_clinic, staff_id: staff.id, clinic_id: clinic.id) }
        let!(:client_enrollment){ create(:client_enrollment) }
        let!(:client_enrollment_service){ create(:client_enrollment_service) }
        let!(:scheduling){ create_list(:scheduling, 5, staff_id: staff.id) }

        let!(:auth_headers) { staff.create_new_auth_token }
        let!(:clients) { create_list(:client, 5, clinic_id: clinic.id) }
        it "should fetch client list of same clinic successfully" do
          set_auth_headers(auth_headers)
          
          get :clients_list
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(clients.count)
        end 

        context "when default_location_id is present" do
          let!(:clinic2){ create(:clinic) }
          let!(:staff_clinic2) { create(:staff_clinic, staff_id: staff.id, clinic_id: clinic2.id) }

          let!(:client_list){ create_list(:client, 5, clinic_id: clinic2.id) }
          it "should fetch client_list of that clinic successfully" do
            set_auth_headers(auth_headers)
          
            get :clients_list, params: { default_location_id: clinic2.id }
            response_body = JSON.parse(response.body)

            expect(response.status).to eq(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data'].count).to eq(client_list.count)
          end
        end
      end

      context "when logged in user is bcba" do
        let!(:clinic1) { create(:clinic) }
        let!(:staff) { create(:staff, :with_role, role_name: 'bcba') }
        let!(:staff_clinic) { create(:staff_clinic, staff_id: staff.id, clinic_id: clinic1.id) }
        let!(:auth_headers) { staff.create_new_auth_token }

        let!(:client_enrollment){ create(:client_enrollment) }
        let!(:client_enrollment_service){ create(:client_enrollment_service) }
        let!(:scheduling){ create_list(:scheduling, 5, staff_id: staff.id) }
        
        let!(:client_list1) { create_list(:client, 5, clinic_id: clinic1.id) }
        let!(:clinic2) { create(:clinic) }
        let!(:client_list2) { create_list(:client, 5, clinic_id: clinic2.id, bcba_id: staff.id) }
        it "should fetch client list of same clinic as well as with bcba_id of staff successfully" do
          set_auth_headers(auth_headers)
          
          get :clients_list
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(client_list1.count || client_list2.count)
        end 

        context "when default_location_id is present" do
          let!(:clinic3){ create(:clinic) }
          let!(:staff_clinic3) { create(:staff_clinic, staff_id: staff.id, clinic_id: clinic3.id) }
          let!(:client_list){ create_list(:client, 6, clinic_id: clinic3.id) }
          it "should fetch client_list of that clinic successfully" do
            set_auth_headers(auth_headers)
          
            get :clients_list, params: { default_location_id: clinic3.id }
            response_body = JSON.parse(response.body)

            expect(response.status).to eq(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data'].count).to eq(client_list.count)
          end
        end
      end
    end
  end
end
