require 'rails_helper'

RSpec.describe ApplicationConfig, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:config_key) }
    it { should validate_uniqueness_of(:config_key) }
  end
end
