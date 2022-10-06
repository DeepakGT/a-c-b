require 'rails_helper'

RSpec.describe Region, type: :model do
  describe 'model the regions'
  subject { Region.create(region: 'atlantic')}
  describe 'validation' do
    it { should validate_presence_of(:region) } 
    it { should validate_uniqueness_of(:region) } 
  end
end