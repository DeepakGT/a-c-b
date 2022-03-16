require 'rails_helper'

RSpec.describe FundingSource, type: :model do
  it { should have_one(:phone_number).dependent(:destroy)}
  it { should have_one(:address).dependent(:destroy)}
  it { should have_many(:client_enrollments).dependent(:nullify) }
  it { should have_many(:clients).through(:client_enrollments) }  
  it { should belong_to(:clinic) }

  it { should define_enum_for(:status)}
  it { should define_enum_for(:network_status)}
  it { should define_enum_for(:payor_type)}

  it { should accept_nested_attributes_for(:phone_number).update_only(true)}
  it { should accept_nested_attributes_for(:address).update_only(true)}
end
