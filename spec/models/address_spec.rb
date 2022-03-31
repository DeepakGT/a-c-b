require 'rails_helper'

RSpec.describe Address, type: :model do
  it { should belong_to(:addressable) }
  it { should define_enum_for(:address_type)}

  context "when country is USA" do
    before { allow(subject).to receive(:is_country_usa?).and_return(true) }
    it{ should validate_length_of(:zipcode).is_equal_to(5) }
  end
end
