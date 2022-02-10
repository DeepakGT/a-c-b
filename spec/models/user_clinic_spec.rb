require 'rails_helper'

RSpec.describe UserClinic, type: :model do
  it { should belong_to(:clinic) }
  it { should belong_to(:staff) }  
end
