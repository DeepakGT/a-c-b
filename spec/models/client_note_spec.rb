require 'rails_helper'

RSpec.describe ClientNote, type: :model do
  it { should belong_to(:client).optional } 

  it { should validate_presence_of(:note) }
end
