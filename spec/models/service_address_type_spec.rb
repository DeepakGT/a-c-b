require 'rails_helper'

RSpec.describe ServiceAddressType, type: :model do
  describe 'model the service address types'
  subject { ServiceAddressType.create(tag_num: rand(0..1000), name: Faker::Name.unique.name)}
  describe 'validation' do
    it { should validate_presence_of(:tag_num) } 
    it { should validate_uniqueness_of(:tag_num) } 
    it { should validate_presence_of(:name) }
  end
end
