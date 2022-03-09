require 'rails_helper'

RSpec.describe StaffClinicService, type: :model do
  it { should belong_to(:staff_clinic) }
  it { should belong_to(:service) }
end
