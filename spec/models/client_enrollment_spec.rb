require 'rails_helper'

RSpec.describe ClientEnrollment, type: :model do
  it { should belong_to(:client) } 
  it { should belong_to(:funding_source) } 

  it { should define_enum_for(:relationship) }
  it { should define_enum_for(:source_of_payment) }

  subject { build :client_enrollment, is_primary: true }
  it { should validate_uniqueness_of(:client_id).scoped_to(:is_primary).with_message('can have only one primary funding source.') }
end
