require 'rails_helper'

RSpec.describe Staff, type: :model do
  it { should have_many(:staff_credentials).dependent(:destroy).with_foreign_key('staff_id')}
  it { should have_many(:credentials).through(:staff_credentials)}
  it { should have_one(:address).dependent(:destroy)}
  it { should have_many(:phone_numbers).dependent(:destroy)}
  it { should have_many(:staff_clinics) } 
  it { should have_many(:clinics).through(:staff_clinics) }
  
  it { should belong_to(:supervisor).class_name('User').optional }

  it { should accept_nested_attributes_for(:address).update_only(true) }
  it { should accept_nested_attributes_for(:phone_numbers).update_only(true) }

  describe "#validate_role" do
    context "when staff is created" do
      let(:staff) { build :staff, :with_role, role_name: 'aba_admin' }
      it "should be rbt,bcba or billing" do
        staff.validate
        expect(staff.errors[:role]).to include('For staff, role must be bcba, rbt or billing.')
      end
    end
  end
end
