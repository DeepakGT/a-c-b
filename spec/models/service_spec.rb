require 'rails_helper'

RSpec.describe Service, type: :model do
  it { should have_many(:user_services).dependent(:destroy)}
  it { should have_many(:users).through(:user_services)}

  it { should define_enum_for(:status)}
end
