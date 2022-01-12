require 'rails_helper'

RSpec.describe Credential, type: :model do
  it { should have_many(:staff_credentials).dependent(:destroy)}
  it { should have_many(:staff).through(:staff_credentials)}
  
  it { should define_enum_for(:credential_type)}
end
