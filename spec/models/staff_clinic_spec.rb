require 'rails_helper'

RSpec.describe StaffClinic, type: :model do
  it { should belong_to(:clinic) }
  it { should belong_to(:staff) }
  it { should have_many(:staff_clinic_services) } 
  it { should have_many(:services).through(:staff_clinic_services) } 

  it { should accept_nested_attributes_for(:staff_clinic_services) }

  it { should validate_uniqueness_of(:clinic_id).scoped_to(:staff_id) }

  subject { build :staff_clinic, is_home_clinic: true}
  it { should validate_uniqueness_of(:staff_id).scoped_to(:is_home_clinic).with_message('can have only one home clinic.') }
end
