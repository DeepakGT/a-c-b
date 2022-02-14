require 'rails_helper'

RSpec.describe ClientNote, type: :model do
  it { should belong_to(:client).optional } 
end
