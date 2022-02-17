require 'rails_helper'

RSpec.describe StaffService, type: :model do
  it { should belong_to(:staff)}
  it { should belong_to(:service)}
end
