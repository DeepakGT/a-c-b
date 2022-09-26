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
        let!(:clients) { create_list(:client, 5, clinic_id: clinic.id) }
        let!(:staff_clinic) { create(:staff_clinic, staff_id: staff.id, clinic_id: clinic.id) }
        let!(:client_enrollment1){ create(:client_enrollment, client_id: clients.first.id) }
        let!(:client_enrollment_service1){ create(:client_enrollment_service, client_enrollment_id: client_enrollment1.id) }
        let!(:scheduling1){ create(:scheduling, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service1.id, date: Date.current - 5.days) }
        let!(:client_enrollment2){ create(:client_enrollment, client_id: clients.last.id) }
        let!(:client_enrollment_service2){ create(:client_enrollment_service, client_enrollment_id: client_enrollment2.id) }
        let!(:scheduling2){ create(:scheduling, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service2.id, date: Date.current - 35.days) }
        let!(:auth_headers) { staff.create_new_auth_token }
        let!(:clients_count) {Client.by_staff_id_in_scheduling(staff.id).with_appointment_after_last_30_days.count}
        it "should fetch client list of same clinic successfully" do
          set_auth_headers(auth_headers)
          
          get :clients_list
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(clients_count)
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
            expect(response_body['data'].count).to eq(Client.by_staff_id_in_scheduling(staff.id).by_clinic(clinic2.id).count)
          end
        end
      end

      context "when logged in user is bcba" do
        let!(:clinic1) { create(:clinic) }
        let!(:clinic2) { create(:clinic) }
        let!(:staff) { create(:staff, :with_role, role_name: 'bcba') }
        let!(:staff_clinic) { create(:staff_clinic, staff_id: staff.id, clinic_id: clinic1.id) }
        let!(:auth_headers) { staff.create_new_auth_token }
        let!(:client_list1) { create_list(:client, 5, clinic_id: clinic1.id) }
        let!(:client_list2) { create_list(:client, 5, clinic_id: clinic2.id, bcba_id: staff.id) }
        let!(:client_enrollment1){ create(:client_enrollment, client_id: client_list1.first.id) }
        let!(:client_enrollment_service1){ create(:client_enrollment_service, client_enrollment_id: client_enrollment1.id) }
        let!(:scheduling1){ create(:scheduling, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service1.id, date: Date.current-20.days) }
        let!(:client_enrollment2){ create(:client_enrollment, client_id: client_list1.last.id) }
        let!(:client_enrollment_service2){ create(:client_enrollment_service, client_enrollment_id: client_enrollment2.id) }
        let!(:scheduling2){ create(:scheduling, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service2.id, date: Date.current-40.days) }
        let!(:client_enrollment3){ create(:client_enrollment, client_id: client_list2.last.id) }
        let!(:client_enrollment_service3){ create(:client_enrollment_service, client_enrollment_id: client_enrollment3.id) }
        let!(:scheduling3){ create(:scheduling, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service3.id, date: Date.current+5.days) }
        let!(:clients_count) {Client.by_staff_id_in_scheduling(staff.id).with_appointment_after_last_30_days.or(Client.by_bcbas(staff.id)).count}
        it "should fetch client list of same clinic as well as with bcba_id of staff successfully" do
          set_auth_headers(auth_headers)
          
          get :clients_list
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(clients_count)
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
            expect(response_body['data'].count).to eq(Client.by_staff_id_in_scheduling(staff.id).by_clinic(clinic3.id).count )
          end
        end
      end
    end
  end
end
