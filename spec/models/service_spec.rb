require 'rails_helper'

RSpec.describe Service, type: :model do
  it { should have_many(:staff_services).dependent(:destroy)}
  it { should have_many(:staff).through(:staff_services)}
  it { should have_many(:client_enrollment_services) } 

  it { should define_enum_for(:status)}
end
