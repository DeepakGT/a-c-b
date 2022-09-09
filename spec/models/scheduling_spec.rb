require 'rails_helper'

RSpec.describe Scheduling, type: :model do
  let!(:role) { create(:role, name: 'executive_director', permissions: ['scheduling_update'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let(:service) { create(:service) }
  let!(:client_enrollment_service) { create(:client_enrollment_service, service_id: service.id, units: 7) }
  let!(:staff) { create(:staff, :with_role, role_name: 'bcba') }

  subject { create(:scheduling, user: user) }
  describe 'associations' do
    it { should belong_to(:staff).optional }
    it { should belong_to(:client_enrollment_service).optional }
    it { should have_many(:soap_notes).dependent(:destroy) } 
    it { should have_many(:scheduling_change_requests).dependent(:destroy) } 
  end
  it { is_expected.to callback(:set_units_and_minutes).before(:save) }
  
  describe "#attr_accessor" do
    let(:scheduling){build :scheduling}
    RSpec::Matchers.define :have_attr_accessor do |user|
      match do |scheduling|
        scheduling.respond_to?(user) &&
          scheduling.respond_to?("#{user}=")
      end
    
      failure_message_for_should do |scheduling|
        "expected attr_accessor for #{user} on #{scheduling}"
      end
    
      failure_message_for_should_not do |scheduling|
        "expected attr_accessor for #{user} not to be defined on #{scheduling}"
      end
    
      description do
        "checks to see if there is an attr accessor on the supplied object"
      end
    end
  end

  describe "validations" do
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
    it { should validate_presence_of(:status) }
  end

  # describe "#validate_time" do
  #   let(:scheduling1) { create(:scheduling, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id, start_time: '16:00', end_time: '17:00', date: '2567-02-28', units: '2')}
  #   let(:scheduling) { build :scheduling, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id, start_time: '16:00', end_time: '17:00', date: '2567-02-28', units: '2' }
    
  #   context "when scheduling with same staff,client, service at same time is present" do
  #     it "should give an error" do
  #       scheduling1.user = user
  #       scheduling.user = user
  #       scheduling.validate
  #       expect(scheduling.errors[:scheduling]).to include('must not have overlapping time for same staff, client and service on same date')
  #     end
  #   end
  # end

  describe "#validate_past_appointments" do
    context "when user is executive_director, clinical director or client care coordinator" do
      let(:scheduling) { build :scheduling, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id, start_time: '16:00', end_time: '17:00', date: Time.current.to_date-4, units: '2' }
      it "cannot add appointment in past 3 days ago" do
        scheduling.user = user
        scheduling.validate
        expect(scheduling.errors[:scheduling]).to include('You are not authorized to create appointments for 3 days ago.')
      end
    end

    context "when user is bcba" do
      let(:role) { create(:role, name: 'bcba', permissions: ['scheduling_update'])}
      let(:user) { create(:user, :with_role, role_name: role.name) }
      let(:scheduling) { build :scheduling, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id, start_time: '16:00', end_time: '17:00', date: Time.current.to_date-2, units: '2' }
      it "cannot add appointment past 24 hours" do
        scheduling.user = user
        scheduling.validate
        expect(scheduling.errors[:scheduling]).to include('You are not authorized to create appointment past 24 hrs.')
      end
    end

    context "when user is other than super_admin, ccc, cd, ed or bcba" do
      let(:role) { create(:role, name: 'administrator', permissions: ['scheduling_update'])}
      let(:user) { create(:user, :with_role, role_name: role.name) }
      let(:scheduling) { build :scheduling, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id, start_time: '16:00', end_time: '17:00', date: Time.current.to_date-1, units: '2' }
      it "cannot add appointment in past" do
        scheduling.user = user
        scheduling.validate
        expect(scheduling.errors[:scheduling]).to include('You are not authorized to create appointment in past.')
      end
    end
  end

  describe "#validate_units" do
    context "when left units is less than units for scheduling" do
      let(:scheduling) { build :scheduling, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id, start_time: '16:00', end_time: '17:00', date: '2022-02-28', units: '8' }
      it "should not create schedules" do
        scheduling.user = user
        scheduling.validate
        expect(scheduling.errors[:units]).to include('left for authorization are not enough to create this appointment.')
      end
    end
  end

  describe "#validate_draft_appointments" do
    context "when logged in user is other than ccc, cd or super_admin" do
      let(:scheduling) { build :scheduling, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id, start_time: '16:00', end_time: '17:00', date: Time.current.to_date+6, units: '8', status: 'draft' }
      it "should not be allowed to create draft appointments" do
        scheduling.user = user
        scheduling.validate
        expect(scheduling.errors[:draft]).to include('appointments can only be created by client care coordinator or clinical director.')
      end
    end
  end
end
