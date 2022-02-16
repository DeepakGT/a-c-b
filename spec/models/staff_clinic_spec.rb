require 'rails_helper'

RSpec.describe StaffClinic, type: :model do
  it { should belong_to(:clinic) }
  it { should belong_to(:staff) }

  subject { build :staff_clinic, is_home_clinic: true}
  it { should validate_uniqueness_of(:staff_id).scoped_to(:is_home_clinic).with_message('can have only one home clinic.') }
end
