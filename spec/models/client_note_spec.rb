require 'rails_helper'

RSpec.describe ClientNote, type: :model do
  it { should belong_to(:client).optional } 
  it { should have_one(:attachment) }

  it { should accept_nested_attributes_for(:attachment).update_only(true) }
end
