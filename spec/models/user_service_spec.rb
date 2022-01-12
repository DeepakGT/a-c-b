require 'rails_helper'

RSpec.describe UserService, type: :model do
  it { should belong_to(:user)}
  it { should belong_to(:service)}
end
