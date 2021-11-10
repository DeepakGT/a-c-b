require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }

  it { should have_one(:user_role).dependent(:destroy)}
  it { should have_one(:role).through(:user_role)}
end
