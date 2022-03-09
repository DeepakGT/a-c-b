require 'rails_helper'

RSpec.describe SoapNote, type: :model do
  it { should belong_to(:scheduling) } 
end
