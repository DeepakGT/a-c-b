require 'rails_helper'

RSpec.describe ClientEnrollmentPayment, type: :model do
  it { should belong_to(:client) }
  it { should belong_to(:funding_source).optional }
  
  it { should define_enum_for(:source_of_payment) }
  it { should define_enum_for(:relationship) }
end
