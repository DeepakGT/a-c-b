require 'rails_helper'

RSpec.describe ServiceQualification, type: :model do
  it { should belong_to(:service) }
  it { should belong_to(:qualification) } 
end
