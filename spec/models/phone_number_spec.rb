require 'rails_helper'

RSpec.describe PhoneNumber, type: :model do
  it { should belong_to(:phoneable).inverse_of(:phoneable) }

  it { should define_enum_for(:phone_type)}
end
