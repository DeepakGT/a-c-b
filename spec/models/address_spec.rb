require 'rails_helper'

RSpec.describe Address, type: :model do
  it { should belong_to(:addressable).inverse_of(:addressable) }
  it { should define_enum_for(:address_type)}
end
