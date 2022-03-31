require 'rails_helper'

RSpec.describe PhoneNumber, type: :model do
  it { should belong_to(:phoneable) }

  it { should define_enum_for(:phone_type)}

  it { is_expected.to callback(:set_default_phone_type).after(:initialize) }
end
