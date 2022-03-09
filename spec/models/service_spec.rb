require 'rails_helper'

RSpec.describe Service, type: :model do
  it { should have_many(:service_qualifications).dependent(:destroy) }
  it { should have_many(:qualifications).through(:service_qualifications) }  
  it { should have_many(:client_enrollment_services) } 
  it { should have_one(:scheduling) }

  it { should accept_nested_attributes_for(:service_qualifications) }

  it { should define_enum_for(:status)}
end
