require 'rails_helper'

RSpec.describe Clinic, type: :model do
  it { should have_one(:address).dependent(:destroy) }
  it { should have_one(:phone_number).dependent(:destroy) }
  it { should have_many(:staff_clinics).dependent(:destroy) } 
  it { should have_many(:staff).through(:staff_clinics) }
  it { should have_many(:clients).dependent(:destroy) } 
  it { should have_many(:funding_sources).dependent(:destroy) }

  it { should belong_to(:organization) }

  it { should accept_nested_attributes_for(:address).update_only(true)}
  it { should accept_nested_attributes_for(:phone_number).update_only(true)}

  it { should define_enum_for(:status)}
  
  it { should delegate_method(:name).to(:organization).with_prefix(true)}
end
