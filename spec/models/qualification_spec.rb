require 'rails_helper'

RSpec.describe Qualification, type: :model do
  it { should have_many(:staff_qualifications).dependent(:destroy)}
  it { should have_many(:staff).through(:staff_qualifications)}
  it { should have_many(:service_qualifications).dependent(:destroy)}
  it { should have_many(:services).through(:service_qualifications)}
  
  it { should define_enum_for(:credential_type)}
end
