require 'rails_helper'

RSpec.describe Client, type: :model do
  it { should have_many(:contacts).dependent(:destroy) } 
end
