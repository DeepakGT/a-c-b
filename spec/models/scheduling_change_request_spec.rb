require 'rails_helper'

RSpec.describe SchedulingChangeRequest, type: :model do
  it { should belong_to(:scheduling) }
  
  it { should define_enum_for(:approval_status) }
end
