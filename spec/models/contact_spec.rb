require 'rails_helper'

RSpec.describe Contact, type: :model do
  it { should belong_to(:client) } 
  
  it { should have_one(:address).dependent(:destroy) }
  it { should have_one(:phone_number).dependent(:destroy) }

  it { should accept_nested_attributes_for(:address).update_only(true) }
  it { should accept_nested_attributes_for(:phone_number).update_only(true) }
end
