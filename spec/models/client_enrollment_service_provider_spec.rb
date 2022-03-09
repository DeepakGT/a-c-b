require 'rails_helper'

RSpec.describe ClientEnrollmentServiceProvider, type: :model do
  it { should belong_to(:client_enrollment_service) }
  it { should belong_to(:staff) } 
end
