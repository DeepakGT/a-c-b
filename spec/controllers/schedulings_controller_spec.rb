require 'rails_helper'
require "support/render_views"

RSpec.describe SchedulingsController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:role) { create(:role, name: 'executive_director', permissions: ['schedule_view', 'schedule_update', 'schedule_delete', 'schedule_update_for_unassigned_staff', 'schedule_update_for_unassigned_client'])}
  let!(:role_ccc) { create(:role, name: Constant.roles['ccc'], permissions: ['schedule_view', 'schedule_update', 'schedule_delete'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:user_ccc) { create(:user, :with_role, role_name: role_ccc.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:auth_headers_ccc) { user_ccc.create_new_auth_token }
  let!(:organization) { create(:organization, name: 'org1', admin_id: user.id) }
  let!(:clinic) { create(:clinic, name: 'clinic1', organization_id: organization.id) }
  let!(:client) { create(:client, clinic_id: clinic.id, first_name: 'test') }
  let!(:service) { create(:service) }
  let!(:client_enrollment) { create(:client_enrollment, client_id: client.id) }
  let!(:client_enrollment_service) { create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, service_id: service.id) }
  let!(:staff) { create(:staff, :with_role, role_name: 'administrator', first_name: 'abcd') }
  
  describe "GET #index" do
    context "when sign in" do
      let!(:schedulings) {create_list(:scheduling, 5, units: '2', staff_id: staff.id, creator_id: user.id)}
      it "should list schedulings successfully" do
        set_auth_headers(auth_headers)
        
        get :index
        response_body = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(Scheduling.all.count)
      end

      it "should fetch the given page record" do
        set_auth_headers(auth_headers)
        
        get :index, params: { page: 2 }
        response_body = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq("2")
      end

      let!(:scheduling1){ create(:scheduling, staff_id: staff.id, creator_id: user.id) }
      let!(:scheduling2){ create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, creator_id: user.id) }
      let!(:scheduling3){ create(:scheduling, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id, creator_id: user.id) }

      context "when client_ids is present" do
        it "should staff filter by client ids successfully" do
          set_auth_headers(auth_headers)
          
          get :index, params: { client_ids: client.id }
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(Scheduling.joins(client_enrollment_service: :client_enrollment).by_client_ids(client.id).count)
        end
      end

      context "when staff_ids is present" do
        it "should staff filter by staff ids successfully" do
          set_auth_headers(auth_headers)
          
          get :index, params: { staff_ids: staff.id }
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(Scheduling.by_staff_ids(staff.id).count)
        end
      end

      context "when service_ids is present" do
        it "should list staff filtered by service ids successfully" do
          set_auth_headers(auth_headers)
          
          get :index, params: { service_ids: service.id }
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(Scheduling.joins(client_enrollment_service: :client_enrollment).by_service_ids(service.id).count)
        end
      end

      context "when staff_ids, client_ids, service_ids and default_location_id is present" do
        it "should list staff filtered by all filters successfully" do
          set_auth_headers(auth_headers)
          
          get :index, params: { service_ids: service.id, staff_ids: staff.id, client_ids: client.id, default_location_id: clinic.id }
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(1)
        end
      end

      context "when no filters are present" do
        let!(:role1) { create(:role, name: 'rbt', permissions: ['schedule_view', 'schedule_update', 'schedule_delete'])}
        let!(:staff1) {create(:staff, :with_role, role_name: role1.name)}
        let!(:role2) { create(:role, name: 'bcba', permissions: ['schedule_view', 'schedule_update', 'schedule_delete'])}
        let!(:staff2) {create(:staff, :with_role, role_name: role2.name)}
        let!(:staff1_auth_headers){ staff1.create_new_auth_token}
        let!(:staff2_auth_headers){ staff2.create_new_auth_token}
        let!(:staff_clinic) {create(:staff_clinic, staff_id: staff.id, clinic_id: clinic.id)}
        let!(:client1) { create(:client, clinic_id: clinic.id, bcba_id: staff2.id) }
        let!(:client_enrollment1) { create(:client_enrollment, client_id: client1.id) }
        let!(:client_enrollment_service1) { create(:client_enrollment_service, client_enrollment_id: client_enrollment1.id) }
        let!(:rbt_scheduling){create(:scheduling, staff_id: staff1.id, client_enrollment_service_id: client_enrollment_service1.id, creator_id: staff1.id)}
        let!(:bcba_scheduling){create(:scheduling, staff_id: staff2.id, client_enrollment_service_id: client_enrollment_service.id, creator_id: staff2.id)}

        context "and logged in user is rbt" do
          it "should show schedules created for rbt" do
            set_auth_headers(staff1_auth_headers)

            get :index
            response_body = JSON.parse(response.body)

            expect(response.status).to eq(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data'].count).to eq(10)
          end
        end

        context "and logged in user is bcba" do
          it "should show schedules created for bcba and schedules for client with bcba_id equal to bcba" do
            set_auth_headers(staff2_auth_headers)

            get :index
            response_body = JSON.parse(response.body)

            expect(response.status).to eq(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data'].count).to eq(10)
          end
        end
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
          date: Time.current.to_date,
          start_time: '16:00',
          end_time: '17:00',
          status: 'scheduled',
          minutes: '288',
          creator_id: user.id
        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_enrollment_service_id']).to eq(client_enrollment_service.id)
        expect(response_body['data']['staff_id']).to eq(staff.id)
        expect(response_body['data']['date']).to eq(Time.current.to_date.to_s)
        expect(response_body['data']['start_time'].split[0]).to eq('04:00')
        expect(response_body['data']['end_time'].split[0]).to eq('05:00')
        expect(response_body['data']['status']).to eq('scheduled')
        expect(response_body['data']['minutes']).to eq(288.0)
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      let(:scheduling) { create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, staff_id: staff.id, date: Date.today, start_time: '9:00', end_time: '10:00', units: '2', creator_id: user.id) }
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
      context "when logged in user is super_admin, administrator and executive_director" do
        let(:scheduling) { create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, staff_id: staff.id, start_time: '12:00', end_time: '13:00', units: '4', creator_id: user.id) }
        it "should update scheduling successfully" do
          set_auth_headers(auth_headers)

          put :update, params: { id: scheduling.id, status: 'unavailable', end_time: '14:00' }
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(scheduling.id)
          expect(response_body['data']['status']).to eq('unavailable')
          expect(response_body['data']['end_time'].split[0]).to eq('02:00')
        end

        context "and update associated data" do
          let(:staff) { create(:staff, :with_role, role_name: 'client_care_coordinator') }
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

      context "when logged in user is bcba" do
        let(:role) {create(:role, name: 'bcba', permissions: ['schedule_update'])}
        let(:bcba_staff) {create(:staff, :with_role, role_name: role.name)}
        let(:staff_auth_headers) {bcba_staff.create_new_auth_token}
        context "and date is in future" do
          let(:scheduling) { create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, staff_id: staff.id, start_time: '12:00', end_time: '13:00', units: '4', creator_id: user.id) }
          it "should update scheduling successfully" do
            set_auth_headers(staff_auth_headers)

            put :update, params: { id: scheduling.id, status: 'unavailable', end_time: '14:00' }
            response_body = JSON.parse(response.body)

            expect(response.status).to eq(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data']['id']).to eq(scheduling.id)
            expect(response_body['data']['status']).to eq('unavailable')
            expect(response_body['data']['end_time'].split[0]).to eq('02:00')
          end
        end

        context "and date is in past" do
          let(:scheduling) { create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, staff_id: staff.id, start_time: '12:00', end_time: '13:00', units: '4', date: Date.today, creator_id: user.id) }
          it "should update scheduling status successfully" do
            set_auth_headers(staff_auth_headers)

            put :update, params: { id: scheduling.id, status: 'unavailable'}
            response_body = JSON.parse(response.body)

            expect(response.status).to eq(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data']['id']).to eq(scheduling.id)
            expect(response_body['data']['status']).to eq('unavailable')
          end

          context "when try to update data other than status" do
            it "should not update scheduling status successfully" do
              set_auth_headers(staff_auth_headers)
  
              put :update, params: { id: scheduling.id, status: 'unavailable', end_time: '13:10'}
              response_body = JSON.parse(response.body)
  
              expect(response.status).to eq(200)
              expect(response_body['status']).to eq('success')
              expect(response_body['data']['id']).to eq(scheduling.id)
              expect(response_body['data']['status']).to eq('unavailable')
              expect(response_body['data']['end_time'].split[0]).to eq('01:10')
            end
          end

          context "when logged_in user is super_admin, ccc or cd and tries to confirm draft appointment" do
            let!(:role1) { create(:role, name: 'client_care_coordinator', permissions: ['schedule_view', 'schedule_update', 'schedule_delete', 'schedule_update_for_unassigned_staff', 'schedule_update_for_unassigned_client'])}
            let!(:user1) { create(:user, :with_role, role_name: role1.name) }
            let!(:auth_headers1) { user1.create_new_auth_token }
            let(:scheduling1) { create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, staff_id: staff.id, start_time: '12:00', end_time: '13:00', units: '4', date: Time.current.to_date+4, status: 'draft') }
            it "should update appointment successfully" do
              set_auth_headers(auth_headers1)
  
              put :update, params: { id: scheduling1.id, status: 'scheduled'}
              response_body = JSON.parse(response.body)
  
              expect(response.status).to eq(200)
              expect(response_body['status']).to eq('success')
              expect(response_body['data']['id']).to eq(scheduling1.id)
              expect(response_body['data']['status']).to eq('scheduled')
            end
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "when sign in" do
      context "and logged in user is other than super admin" do
        let(:scheduling) { create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, staff_id: staff.id, start_time: '17:00', end_time: '18:00', units: '2', creator_id: user.id) }
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

      context "and logged in user is super admin" do
        let(:user) { create(:user, :with_role, role_name: 'super_admin') }
        let(:auth_headers) { user.create_new_auth_token }
        let(:scheduling) { create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, staff_id: staff.id, start_time: '17:00', end_time: '18:00', units: '2', creator_id: user.id) }
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

  describe "POST #create_without_staff" do
    context "when sign in" do
      it "should create scheduling without staff successfully" do
        set_auth_headers(auth_headers)
        
        post :create_without_staff, params: {
          client_enrollment_service_id: client_enrollment_service.id,
          date: Time.current.to_date,
          start_time: '13:00',
          end_time: '15:00',
          minutes: '188',
          creator_id: user.id
        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['start_time'].split[0]).to eq('01:00')
        expect(response_body['data']['end_time'].split[0]).to eq('03:00')
        expect(response_body['data']['status']).to eq('non_billable')
        expect(response_body['data']['minutes']).to eq(188.0)
      end
    end
  end

  describe "POST #create_without_client" do
    context "when sign in" do
      let(:staff) { create(:staff, :with_role, role_name: 'bcba') }
      it "should create scheduling without client successfully" do
        set_auth_headers(auth_headers)
        
        post :create_without_client, params: {
          staff_id: staff.id,
          date: Time.current.to_date,
          start_time: '13:00',
          end_time: '15:00',
          creator_id: user.id
        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['start_time'].split[0]).to eq('01:00')
        expect(response_body['data']['end_time'].split[0]).to eq('03:00')
        expect(response_body['data']['status']).to eq('non_billable')
      end
    end
  end

  describe "PUT #update_without_client" do
    context "when sign in" do
      let(:staff) { create(:staff, :with_role, role_name: 'bcba') }
      let!(:scheduling){ create(:scheduling, client_enrollment_service_id: nil, status: 'non_billable', date: Date.today, start_time: '13:00', end_time: '15:00', creator_id: user.id) }
      let(:staff2) { create(:staff, :with_role, role_name: 'rbt') }
      it "should create scheduling without client successfully" do
        set_auth_headers(auth_headers)
        
        put :update_without_client, params: {
          id: scheduling.id,
          staff_id: staff.id,
          date: Date.today,
          start_time: '10:00',
          end_time: '15:00'
        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['start_time'].split[0]).to eq('10:00')
        expect(response_body['data']['end_time'].split[0]).to eq('03:00')
        expect(response_body['data']['date']).to eq(Time.now.strftime('%Y-%m-%d'))
        expect(response_body['data']['status']).to eq('non_billable')
      end
    end
  end

  describe "GET #split_appointment_detail" do
    context "when sign in" do
      let!(:scheduling) { create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, staff_id: staff.id, date: Date.today, start_time: '9:00', end_time: '10:00', units: '4', unrendered_reason: ['split_appointments'], creator_id: user.id) }
      let!(:catalyst_data1){ create(:catalyst_data, system_scheduling_id: scheduling.id, start_time: '09:00', end_time: '09:30', units: 2, date: Date.today, session_location: 'Home')}
      let!(:catalyst_data2){ create(:catalyst_data, system_scheduling_id: scheduling.id, start_time: '09:30', end_time: '10:00', units: 2, date: Date.today, session_location: 'Community')}
      it "should fetch scheduling detail successfully" do
        scheduling.update(catalyst_data_ids: [catalyst_data1.id, catalyst_data2.id])
        set_auth_headers(auth_headers)
        
        get :split_appointment_detail, params: { id: scheduling.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(scheduling.id)
        expect(response_body['data']['unrendered_reasons']).to eq(['split_appointments'])
        expect(response_body['data']['is_rendered']).to eq(false)
        expect(response_body['data']['catalyst_data'].count).to eq(scheduling.catalyst_data_ids.count)
      end
    end
  end

  describe "PUT #render_appointment" do
    context "when sign in" do
      let!(:scheduling) { create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, staff_id: staff.id, date: Date.today, start_time: '9:00', end_time: '10:00', units: '4', creator_id: user.id) }
      it "should render appointment manually" do
        set_auth_headers(auth_headers)

        put :render_appointment, params: {scheduling_id: scheduling.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(scheduling.id)
        expect(response_body['data']['is_rendered']).to eq(true)
        expect(response_body['data']['rendered_at']).not_to eq(nil)
        expect(response_body['data']['rendered_by']).not_to eq(nil)
        expect(response_body['data']['status']).not_to eq('scheduled')
      end
    end
  end

  describe "POST #create_split_appointment" do
    context "when sign in" do
      let!(:scheduling) { create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, staff_id: staff.id, date: Date.today, start_time: '9:00', end_time: '10:00', units: '4', unrendered_reason: ['split_appointments'], creator_id: user.id) }
      let!(:catalyst_data1){ create(:catalyst_data, system_scheduling_id: scheduling.id, start_time: '09:00', end_time: '09:30', units: 2, date: Date.today, session_location: 'Home')}
      let!(:catalyst_data2){ create(:catalyst_data, system_scheduling_id: scheduling.id, start_time: '09:30', end_time: '10:00', units: 2, date: Date.today, session_location: 'Community')}
      it "should create split appointment successfully" do
        scheduling.update(catalyst_data_ids: [catalyst_data1.id, catalyst_data2.id])
        set_auth_headers(auth_headers)

        post :create_split_appointment, params: {
          schedule_id: scheduling.id, 
          date: Date.today,
          client_enrollment_service_id: client_enrollment_service.id,
          client_id: client.id,
          staff_id: staff.id,
          split_schedules: [{start_time: '09:00', end_time: '09:30', catalyst_data_id: catalyst_data1.id, units: 2, status: 'scheduled'}, 
                            {start_time: '09:30', end_time: '10:00', catalyst_data_id: catalyst_data2.id, units: 2, status: 'scheduled'}]
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(scheduling.catalyst_data_ids.count)
        expect(Scheduling.find_by_id(scheduling.id)).to eq(nil)
      end
    end
  end

  describe "POST #range_recurrences" do
    context "when sign in" do
      it "should create range recurrences to successfully" do
        set_auth_headers(auth_headers)

        post :range_recurrences, params: {
          client_enrollment_service_id: client_enrollment_service.id,
          staff_id: staff.id,
          status: "scheduled",
          date: Date.today,
          start_time: "10:00",
          end_time: "15:00",
          units: "10",
          minutes: 10 * 15,
          is_rendered: true,
          cross_site_allowed: true,
          service_address_id: 7,
          creator_id: user.id,
          range_recurrences: {start: Date.today, end: Date.today + 1.week}
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(Scheduling.count)
      end
    end
  end

  describe "POST #pattern_recurrences" do
    context "when sign in" do
      it "should create pattern_recurrences Daily to successfully" do
        set_auth_headers(auth_headers)

        post :pattern_recurrences, params: {
          client_enrollment_service_id: client_enrollment_service.id,
          staff_id: staff.id,
          status: "scheduled",
          date: Date.today,
          start_time: "10:00",
          end_time: "15:00",
          units: "10",
          minutes: 10 * 15,
          is_rendered: true,
          cross_site_allowed: true,
          service_address_id: 7,
          creator_id: user.id,
          recurrcer_pattern: {recurrence: 'daily', quantity: 4, days: [0]}
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(Scheduling.count)
      end

      it "should create pattern_recurrences weekly to successfully" do
        set_auth_headers(auth_headers)

        post :pattern_recurrences, params: {
          client_enrollment_service_id: client_enrollment_service.id,
          staff_id: staff.id,
          status: "scheduled",
          date: Date.today,
          start_time: "10:00",
          end_time: "15:00",
          units: "10",
          minutes: 10 * 15,
          is_rendered: true,
          cross_site_allowed: true,
          service_address_id: 7,
          creator_id: user.id,
          recurrcer_pattern: {recurrence: 'weekly', quantity: 4, days: [0]}
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(Scheduling.count)
      end

      it "should create pattern_recurrences monthly to successfully" do
        set_auth_headers(auth_headers)

        post :pattern_recurrences, params: {
          client_enrollment_service_id: client_enrollment_service.id,
          staff_id: staff.id,
          status: "scheduled",
          date: Date.today,
          start_time: "10:00",
          end_time: "15:00",
          units: "10",
          minutes: 10 * 15,
          is_rendered: true,
          cross_site_allowed: true,
          service_address_id: 7,
          creator_id: user.id,
          recurrcer_pattern: {recurrence: 'monthly', quantity: 4, days: [0]}
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(Scheduling.count)
      end

      it "should create pattern_recurrences yearly to successfully" do
        set_auth_headers(auth_headers)

        post :pattern_recurrences, params: {
          client_enrollment_service_id: client_enrollment_service.id,
          staff_id: staff.id,
          status: "scheduled",
          date: Date.today,
          start_time: "10:00",
          end_time: "15:00",
          units: "10",
          minutes: 10 * 15,
          is_rendered: true,
          cross_site_allowed: true,
          service_address_id: 7,
          creator_id: user.id,
          recurrcer_pattern: {recurrence: 'monthly', quantity: 4, days: [0]}
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(Scheduling.count)
      end
    end
  end

  describe "POST #create" do
    context "when sign in" do
      it "expect create draft scheduling successfully" do
        set_auth_headers(auth_headers_ccc)
        
        post :create, params: {
          client_enrollment_service_id: client_enrollment_service.id,
          staff_id: staff.id,
          date: Time.current.to_date,
          start_time: '16:00',
          end_time: '17:00',
          status: 'draft',
          minutes: '288',
          creator_id: user.id
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_enrollment_service_id']).to eq(client_enrollment_service.id)
        expect(response_body['data']['staff_id']).to eq(staff.id)
        expect(response_body['data']['date']).to eq(Time.current.to_date.to_s)
        expect(response_body['data']['start_time'].split[0]).to eq('04:00')
        expect(response_body['data']['end_time'].split[0]).to eq('05:00')
        expect(response_body['data']['status']).to eq('draft')
        expect(response_body['data']['minutes']).to eq(288.0)
      end
    end
  end
end
