require 'rails_helper'

RSpec.describe RbtSupervision, type: :model do
  it { should belong_to(:user)}

  it { should define_enum_for(:status)}
end
