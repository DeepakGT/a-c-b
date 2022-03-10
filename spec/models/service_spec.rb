require 'rails_helper'

RSpec.describe Service, type: :model do
  it { should have_many(:service_qualifications).dependent(:destroy) }
  it { should have_many(:qualifications).through(:service_qualifications) }  
  it { should have_many(:client_enrollment_services).dependent(:destroy) } 
  it { should have_many(:schedulings).dependent(:destroy) }
  it { should have_many(:staff_clinic_services).dependent(:destroy) }
  it { should have_many(:staff_clinics).through(:staff_clinic_services) }  

  it { should accept_nested_attributes_for(:service_qualifications) }

  it { should define_enum_for(:status)}

  context "display code must contain alphanumeric characters only." do
    it { should allow_value("Abc342").for(:display_code) }
    it { should_not allow_value("test2$!@#%^&*_").for(:display_code) }
  end
end
