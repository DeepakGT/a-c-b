require 'rails_helper'

RSpec.describe Client, type: :model do
  it { should have_many(:contacts).dependent(:destroy) } 
  it { should have_many(:addresses).dependent(:destroy) }
  it { should have_one(:phone_number).dependent(:destroy) }
  it { should have_many(:client_enrollments).dependent(:destroy) }
  it { should have_many(:funding_sources).through(:client_enrollments) }  

  it { should accept_nested_attributes_for(:addresses).update_only(true)}
  it { should accept_nested_attributes_for(:phone_number).update_only(true)}
end
