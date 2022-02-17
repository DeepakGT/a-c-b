require 'rails_helper'

RSpec.describe ClientEnrollment, type: :model do
  it { should belong_to(:client) } 
  it { should belong_to(:funding_source).optional } 
  it { should have_many(:client_enrollment_services) } 

  it { should define_enum_for(:relationship) }
  it { should define_enum_for(:source_of_payment) }
end
