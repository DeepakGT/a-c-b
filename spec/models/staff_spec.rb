require 'rails_helper'

RSpec.describe Staff, type: :model do
  it { should have_many(:staff_qualifications).dependent(:destroy).with_foreign_key('staff_id')}
  it { should have_many(:qualifications).through(:staff_qualifications)}
  it { should have_one(:address).dependent(:destroy)}
  it { should have_many(:phone_numbers).dependent(:destroy)}
  it { should have_many(:staff_clinics) } 
  it { should have_many(:clinics).through(:staff_clinics) }
  it { should have_many(:client_enrollment_service_providers) } 
  it { should have_many(:client_enrollment_services).through(:client_enrollment_service_providers) } 
  it { should have_one(:scheduling)}
  
  it { should belong_to(:supervisor).class_name('User').optional }

  it { should accept_nested_attributes_for(:address).update_only(true) }
  it { should accept_nested_attributes_for(:phone_numbers).update_only(true) }

  describe "#validate_role" do
    context "when staff is created" do
      let(:staff) { build :staff, :with_role, role_name: 'super_admin' }
      it "should not be super_admin" do
        staff.validate
        expect(staff.errors[:role]).to include('cannot be super_admin for staff.')
      end
    end
  end
end
