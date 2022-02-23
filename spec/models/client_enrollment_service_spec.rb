require 'rails_helper'

RSpec.describe ClientEnrollmentService, type: :model do
  it { should belong_to(:client_enrollment) } 
  it { should belong_to(:service) } 

  it { should have_many(:service_providers).class_name('ClientEnrollmentServiceProvider').dependent(:destroy) } 
  it { should have_many(:staff).through(:service_providers) }
   
  it { should accept_nested_attributes_for(:service_providers) }
end
