require 'rails_helper'

RSpec.describe ClientEnrollment, type: :model do
  it { should belong_to(:client) } 
  it { should belong_to(:funding_source) } 
end
