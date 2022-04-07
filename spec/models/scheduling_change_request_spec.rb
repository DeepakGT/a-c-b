require 'rails_helper'

RSpec.describe SchedulingChangeRequest, type: :model do
  describe '#associations' do
    subject { create(:scheduling_change_request) }
    it { should belong_to(:scheduling) }
  end
  
  describe '#enums' do
    it { should define_enum_for(:approval_status) }
  end
end
